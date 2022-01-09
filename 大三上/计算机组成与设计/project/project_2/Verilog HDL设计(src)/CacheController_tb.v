`timescale 1ns/1ps

module CacheController_tb;
    parameter dely = 10;

    // inputs
    reg clk, reset;
    reg ld, st;             // 读/写指令，高电平有效
    reg [31:0] addr;        // 输入地址
    reg [20:0] tag0_loaded; // 组中第一个块的tag
    reg [20:0] tag1_loaded; // 组中第二个块的tag
    reg valid0, valid1;     // 组中两块的valid位
    reg dirty;              // 是否为脏块
    reg l2_ack;

    // outputs
    wire hit, miss;         // 缓存命中/未命中，高电平有效
    wire load_ready;        // 可从L1D读取数据到CPU，高电平有效
    wire write_l1;          // 可将数据从CPU写入L1D，高电平有效
    wire read_l2;           // 可从L2读取数据到L1D，高电平有效
    wire write_l2;          // 可将数据从L1D写回缓冲/L2，高电平有效

    // Instantiate the Unit Under Test(UUT)
    CacheController_Logic inst(
    // CacheController_FSM inst(
        // inputs
        .clk(clk), 
        .reset(reset), 
        .ld(ld), 
        .st(st), 
        .addr(addr), 
        .tag0_loaded(tag0_loaded), 
        .tag1_loaded(tag1_loaded), 
        .valid0(valid0), 
        .valid1(valid1), 
        .dirty(dirty),  
        .l2_ack(l2_ack),

        // outputs
        .hit(hit), 
        .miss(miss), 
        .load_ready(load_ready), 
        .write_l1(write_l1), 
        .read_l2(read_l2), 
        .write_l2(write_l2)
    );

    // clk
    initial begin
        clk = 0;
        forever #(dely/2) clk = ~clk;
    end

    // reset
    initial begin
        reset = 1;
        #(dely) reset = 0;    // 初始化完成，此时控制器处于Idle
    end

    // inputs
    initial begin
        ld = 0; st = 0;
        addr = {21'h1, 6'h0, 5'h0};       // 地址
        tag0_loaded = 21'h1; valid0 = 0;  // 第一个块
        tag1_loaded = 21'h3; valid1 = 0;  // 第二个块
        dirty = 0; l2_ack = 0;

        // 读未命中、非脏块，假设新分配的行为第一个块
        #(dely*3) ld = 1;     
        #(dely)               // 发出读取指令，控制器转移到CompareTag
                              // 第一个块valid位为0，第二个块tag不匹配，故未命中
        #(dely*8) l2_ack = 1; // 进入ReadData状态，等待8个周期从L2读取数据到L1D
                  valid0 = 1;
        #(dely)   l2_ack = 0; // 数据读取完毕，valid位置为1，回到CompareTag
        #(dely)   ld = 0;     // 输出load_ready=1，回到Idle

        // 读未命中、脏块，假设新分配的行为第二个块
        #(dely)   addr = {21'h3, 6'h0, 5'h0}; // 修改地址，第二个块
                  dirty = 1;  // 第二个块改为脏块
        #(dely)   ld = 1;     
        #(dely)               // 发出读取指令，控制器转移到CompareTag
                              // 第一个块tag不匹配，第二个块valid位为0，故未命中
        #(dely*8)             // 进入WriteBuffer状态，等待8个周期将数据写进缓冲
        #(dely*8) l2_ack = 1; // 进入ReadData状态，等待8个周期从L2读取数据到L1D
                  valid1 = 1;
        #(dely)   l2_ack = 0; // 数据读取完毕，valid位置为1，回到CompareTag
        #(dely)   ld = 0;       // 输出load_ready=1，回到Idle
                  
        // 读命中
        #(dely)   addr = {21'h1, 6'h0, 5'h0}; // 修改地址，第一个块
        #(dely)   ld = 1;     
        #(dely)               // 发出读取指令，控制器转移到CompareTag
                              // 第一个块tag匹配，且valid位为1，故命中
        #(dely)   ld = 0;     // 输出load_ready = 1，回到Idle

        // 写未命中
        #(dely)   valid0 = 0; // 第一个块valid位改为0
        #(dely)   st = 1;
        #(dely)               // 发出写入指令，控制器转移到CompareTag
                              // 第一个块valid位为0，第二个块tag不匹配，故未命中
        #(dely*8)             // 进入WriteBuffer状态，等待8个周期将数据写入缓冲
        #(dely)   st = 0;     // 数据写入完毕，回到Idle

        // 写命中
        #(dely)   addr = {21'h3, 6'h0, 5'h0}; // 修改地址，第二个块
        #(dely)   st = 1;
        #(dely)               // 发出写入指令，控制器转移到CompareTag
                              // 第二个块tag匹配，且valid位为1，故命中
        #(dely)   st = 0;     // 输出write_l1 = 1，回到Idle

        #(dely*2) $stop;
    end
endmodule