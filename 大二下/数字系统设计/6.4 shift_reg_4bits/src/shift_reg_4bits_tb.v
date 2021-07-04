`timescale 1ns / 1ps

module shift_reg_4bits_tb;
	reg clk, reset, in; // 输入
	wire[3:0] out; // 输出
	
	shift_reg_4bits uut(
		.clk(clk), 
		.reset(reset), 
		.in(in), 
		.out(out));
	
	always #50 clk = ~clk;
	
	initial 
	begin
		clk = 0; reset = 1; in = 0; // 初始化
		#(100) reset = 0;
		#(50) in = 1;
		#(50) in = 0;
		#(50) in = 0;
		#(50) in = 1;
		#(55) in = 0;
		#(45) in = 1;
		#(50) in = 1;
		#(50) in = 0;
		#100 $stop;
	end
endmodule