`timescale 1ns / 1ps

module mux4_1_tb;
	reg in0, in1, in2, in3; // 输入
	reg[1:0] sel;
	
	wire out; // 输出
	
	mux4_1 uut(
		.in0(in0),
		.in1(in1),
		.in2(in2),
		.in3(in3),
		.sel(sel),
		.out(out));
	
	initial 
	begin
		in0 = 0; in1 = 0; in2 = 0; in3 = 0;
		
		in0 = 1;
		sel = 2'b00; // 选择in0
		
		#100
		
		in0 = 0; in1 = 1;
		sel = 2'b01; // 选择in1
		
		#100
		
		in0 = 1; in1 = 1; in2 = 0; in3 = 1;
		sel = 2'b10; // 选择in2
		
		#100
		
		in0 = 0; in1 = 0; in2= 0; in3 = 1;
		sel = 2'b11; // 选择in3
		
		#100 $stop;
	end
endmodule