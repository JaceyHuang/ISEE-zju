`timescale 1ns / 1ps

module light_tb;
	reg clk, reset;
	wire[7:0] q; // 8盏灯的亮灭
	
	// 实例化被测单元
	light uut(
		.clk(clk), 
		.reset(reset), 
		.q(q));
		
	always #50 clk = ~clk;
	
	initial 
	begin
		clk = 0; reset = 0; // 初始化
		#(49) reset = 1; // 清零
		#(100) reset = 0; // 正常运作
		#(1500) $stop; // 一个周期
	end
endmodule