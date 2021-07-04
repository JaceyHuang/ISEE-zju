`timescale 1ns / 1ps

module counter_n_tb;
	reg clk; // 输入
	reg en;
    reg r;

	wire co; // 输出
    wire[9:0] q;

	// 实例化被测单元
	counter_n #(.n(1000), .counter_bits(10)) uut (
		.clk(clk),
        .r(r), 
		.en(en), 
		.co(co),
        .q(q));

	//clk时钟信号
    always #50 clk = ~clk;
	
	// clr
	initial 
	begin
		clk = 0; r = 0; en = 0; // 初始化
        #(51) r = 1; // 复位
		#(100)r = 0; en = 1;
        #(800)
        repeat (1000)  
		begin 
			#(100*3)  en = 1; // 使能
			# 100  en = 0; 
		end
        #100 $stop;
	end
endmodule

