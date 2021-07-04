`timescale 1ns / 1ps

module seq1101_tb;
	reg clk, reset, in; // 输入
	wire out; // 输出
	
	// 实例化被测单元
	seq1101 uut(
		.clk(clk), 
		.reset(reset), 
		.in(in), 
		.out(out));
		
	always #50 clk = ~clk; // 时钟信号
	
	initial
	begin
		clk = 0; reset = 0; in = 0;
		#(20) reset = 1; // 清零
		#(101) reset = 0; in = 0; // 正常运作
		#(100) in = 1;
		#(100) in = 1;
		#(100) in = 0; // s3
		#(100) in = 1; // 检测到第一个1101
		#(100) in = 1; // s2
		#(100) in = 0;
		#(100) in = 1; // 两个1101“串联”
		#(100) in = 0; // s0
		#(100) in = 1; // s1
		#(100) in = 1; // s2
		#(100) in = 1; // s2
		#(100) in = 0; // s3
		#(100) in = 1; // s4
		#(100) in = 0; // s0
		#(100) in = 1; // s1
		#(100) in = 0; // s0
		#100 $stop;
	end
endmodule