`timescale 1ns / 1ps

module pal_se_4bits_tb;
	reg clk, reset, load;
	reg[3:0] in; // 输入
	wire out; // 输出
	
	// 实例化被测单元
	pal_se_4bits uut(
		.clk(clk),
		.reset(reset),
		.load(load),
		.in(in),
		.out(out));
		
	always #50 clk = ~clk;
	
	initial 
	begin
		clk = 0; reset = 0; load = 0; in = 4'b0;
		#(49) reset = 1; // 清零
		#(100) reset = 0; in = 4'b1011; load = 1; // 载入1011
		#(50) load = 0; 
		#(250) in = 4'b0101; load = 1; // 载入0101(此时1011尚未全部输出完毕)
		#(50) load = 0;
		#(450) in = 4'b1001; load = 1; // 载入1001
		#(50) load = 0;
		#500 $stop;
	end
endmodule