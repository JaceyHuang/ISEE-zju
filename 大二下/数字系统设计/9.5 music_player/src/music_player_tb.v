`timescale 1ns / 1ps

module music_player_tb;
	reg clk_10m, reset;
	wire speaker;

	// 实例化被测单元
	music_player uut(
		.clk_10m(clk_10m), 
		.reset(reset), 
		.speaker(speaker));
		
	always #50 clk_10m = ~clk_10m;
	
	initial
	begin
		clk_10m = 0; reset = 0; // 初始化
		#(49) reset = 1;
		#(150) reset = 0;
	end
endmodule