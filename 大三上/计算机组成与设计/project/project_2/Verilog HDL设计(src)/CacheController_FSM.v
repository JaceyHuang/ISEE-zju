module CacheController_FSM(clk, reset, ld, st, addr, tag0_loaded, tag1_loaded, valid0, valid1, dirty, l2_ack, 
                           hit, miss, load_ready, write_l1, read_l2, write_l2);
    input clk, reset;
    input ld, st;             // 读/写指令，高电平有效
    input [31:0] addr;        // 输入地址
    input [20:0] tag0_loaded; // 组中第一个块的tag
    input [20:0] tag1_loaded; // 组中第二个块的tag
    input valid0, valid1;     // 组中两块的valid位
    input dirty;              // 是否为脏块，高电平有效
    input l2_ack;             // 数据已从L2读取到L1D，高电平有效

    output hit, miss;         // 缓存命中/未命中，高电平有效
    output reg load_ready;        // 可从L1D读取数据到CPU，高电平有效
    output reg write_l1;          // 可将数据从CPU写入L1D，高电平有效
    output reg read_l2;           // 可从L2读取数据到L1D，高电平有效
    output reg write_l2;          // 可将数据从L1D写回缓冲/L2，高电平有效

    wire [20:0] tag;          // 输入地址中的tag
    wire hit0, hit1;          // 命中组中第一/第二个块
    wire WB_ack;              // 数据已从L1D写入到缓冲/L2，高电平有效

    // 状态编码
    parameter Idle = 2'b00, CompareTag = 2'b01, WriteBuffer = 2'b10, ReadData = 2'b11;
    reg [1:0] state, nextstate;

    // 命中判断电路部分
    assign tag = addr[31:11];
    assign hit0 = (tag0_loaded==tag)&&valid0;      // 组中第一个块是否命中
    assign hit1 = (tag1_loaded==tag)&&valid1;      // 组中第二个块是否命中
    assign hit = (ld||st)&&(hit0||hit1);           // 缓存是否命中
    assign miss = ~hit;                            // 缓存是否未命中

    // WriteBuffer计数器
    counter_n #(.n(8), .counter_bits(3)) WB_counter(.clk(clk), 
                                                    .en(write_l2),       // 当可将数据从L1D写回L2时，开始计数
                                                    .r(~write_l2|reset), // 当不可写回数据或系统重置时，计数器不工作
                                                    .co(WB_ack),         // 计数满8个周期，数据写完，输出WB_ack=1
                                                    .q());
    // 控制器(有限状态机)
    always @ (posedge clk) 
    begin
        if (reset) state = Idle; // 重置为空闲态
        else state = nextstate;    
    end

    always @ (*) 
    begin
        case (state)
            Idle:       begin  
                            // 状态转移
                            if (ld||st) nextstate = CompareTag; // 指令输入，转移到CompareTag
                            else        nextstate = Idle;       // 否则保持Idle
                            // 空闲态输出控制信号为0
                            load_ready = 0; write_l1 = 0; read_l2 = 0; write_l2 = 0; 
                        end
            CompareTag: begin 
                            // 输出和状态转移与输入条件有关
                            if (hit&&ld) 
                            begin
                                // 读命中，CPU从L1D读取数据
                                nextstate = Idle; load_ready = 1; 
                            end 
                            else if (hit&&st)
                            begin
                                // 写命中，CPU将数据写入L1D
                                nextstate = Idle; write_l1 = 1;
                            end
                            else if ((miss&&ld&&dirty)||(miss&&st))
                            begin
                                // 读未命中，分配的行为脏块或写未命中，将数据写入缓冲/L2
                                nextstate = WriteBuffer; write_l2 = 1;
                            end
                            else // 读未命中，分配的行不是脏块，从L2中读取数据到L1D
                            begin
                                nextstate = ReadData; read_l2 = 1;
                            end
                        end
            WriteBuffer:begin
                            // 进入WriteBuffer状态，向缓冲/L2写数据，WB_counter开始计数
                            if (~WB_ack)
                            begin
                                // 还未写满8个时钟周期，状态保持，同时计数允许信号保持为1
                                nextstate = WriteBuffer; write_l2 = 1;
                            end
                            else if (ld&&WB_ack)
                            begin
                                // 读操作且写满8个周期（从读未命中且脏块而来）
                                // 从L2读取数据到L1D，同时计数结束
                                nextstate = ReadData; read_l2 = 1; write_l2 = 0;
                            end
                            else // 写操作且写满8个周期（从写未命中而来），指令完成
                            begin
                                nextstate = Idle; write_l2 = 0;
                            end
                        end
            ReadData:   begin
                            // 从L2读取数据到L1D，需要8个时钟周期
                            if (~l2_ack) 
                            begin
                                // 未满8个周期，状态保持
                                nextstate = ReadData; read_l2 = 1;
                            end
                            else // 数据读取完毕，重新比较标志
                            begin
                                nextstate = CompareTag; read_l2 = 0;
                            end
                        end
            default:    begin // 默认为空闲态，输出控制信号为0
                            nextstate = Idle; 
							load_ready = 0; write_l1 = 0; read_l2 = 0; write_l2 = 0;
                        end
        endcase
    end

endmodule