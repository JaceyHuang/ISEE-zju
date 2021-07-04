`timescale 1ns / 1ps

module JK_trigger_tb;
	reg clk, J, K;
	wire q, qn;
	
	// 实例化被测单元
	JK_trigger uut(
		.clk(clk), 
		.J(J), 
		.K(K), 
		.q(q), 
		.qn(qn));
		
	always #50 clk = ~clk;
	
	initial
	begin
		clk = 0; J = 1; K = 0;// 初始化
		#(100)
		repeat (2)
		begin
		#(100) J = 0; K = 1; // q置0		
		#(100) J = 1; K = 0; // q置1	
		#(100) J = 1; K = 1; // 翻转
		#(100) J = 0; K = 0; // 保持
		end
		#100 $stop;
	end
endmodule