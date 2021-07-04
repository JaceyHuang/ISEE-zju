`timescale 1ns / 1ps

module comp_8bits_tb;
	reg[7:0] in; // 输入
	wire[7:0] out; // 输出
	
	// 实例化被测单元
	comp_8bits uut(
		.in(in), 
		.out(out));
	
	initial 
	begin
		in = 0;
		#(50) in = 8'b00011011;
		#(50) in = 8'b01001001;
		#(50) in = 8'b10000000;
		#(50) in = 8'b11010110;
		#(50) in = 8'b10101010;
		#(50) in = 8'b11111111;
		#(50) in = 8'b10011100;
		#50 $stop;
	end
endmodule