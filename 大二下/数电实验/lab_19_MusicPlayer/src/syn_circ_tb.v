`timescale 1ns / 1ps

module syn_cicr_tb;
	reg clk; // 输入
	reg in;
	
	wire out; // 输出
	
	// 实例化被测单元
	syn_circ uut(
		.clk(clk),
		.in(in),
		.out(out));
		
	always #50 clk = ~clk; // clk时钟信号
	
	initial
	begin
		clk = 0; in = 0; // 初始化
		#(10) in = 0; 
		#(10) in = 1;
		#(10) in = 0;
		repeat (20) // 不同步周期信号
		begin
			#(20*3) in = 1;
			#(20) in = 0;
		end
		repeat (30) // 另外一种输入脉冲
		begin
			#(10) in = 1;
			#(10*2) in = 0;
		end
		#100 $stop;
	end
endmodule