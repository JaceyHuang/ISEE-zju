module CacheController_Logic(clk, reset, ld, st, addr, tag0_loaded, tag1_loaded, valid0, valid1, dirty, l2_ack,
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
    output load_ready;        // 可从L1D读取数据到CPU，高电平有效
    output write_l1;          // 可将数据从CPU写入L1D，高电平有效
    output read_l2;           // 可从L2读取数据到L1D，高电平有效
    output write_l2;          // 可将数据从L1D写回缓冲/L2，高电平有效

    wire [20:0] tag;          // 输入地址中的tag
    wire hit0, hit1;          // 命中组中第一/第二个块
    wire WB_ack;              // 数据已从L1D写入到缓冲/L2，高电平有效
    wire D0, D1;              // D触发器输入
    wire Q0, Q1;              // D触发器输出
    wire w1, w2, w3;          // 内部信号，D触发器输出的三个组合

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
    // 控制器(逻辑电路)
    // 两个4选1数据选择器
    mux4_1 mux0(.in({1'b1, ld&&WB_ack, miss&&ld&&(~dirty), ld||st}), .addr({Q1, Q0}), .out(D0));
    mux4_1 mux1(.in({~l2_ack, ld||(~WB_ack), miss, 1'b0}), .addr({Q1, Q0}), .out(D1));

    // 两个D触发器
    dffre d0(.d(D0), .en(1'b1), .r(reset), .clk(clk), .q(Q0));
    dffre d1(.d(D1), .en(1'b1), .r(reset), .clk(clk), .q(Q1));
    
    assign w1 = (~Q1)&&Q0;
    assign w2 = Q1&&(~Q0);
    assign w3 = Q1&&Q0;

    // 输出信号
    assign load_ready = w1&&hit&&ld;
    assign write_l1 = w1&&hit&&st;
    assign write_l2 = (w1&&((miss&&ld&&dirty)||(miss&&st)))||(w2&&(~WB_ack));
    assign read_l2 = (w1&&miss&&ld&&(~dirty))||(w2&&ld&&WB_ack)||(w3&&(~l2_ack));

endmodule