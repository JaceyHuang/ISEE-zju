`timescale 1ns / 1ps

module counter_8bits_tb;
	reg clk, reset; // 输入
	wire[7:0] q; // 输出
	
	// 实例化被测单元
	counter_8bits uut(
		.clk(clk), 
		.reset(reset), 
		.q(q));
		
	always #50 clk = ~clk; // 时钟信号
	
	initial 
	begin
		clk = 0; reset = 0;
		#(1) reset = 1; // 复位
		#(1000)reset = 0;
        #30000 $stop;
	end
endmodule