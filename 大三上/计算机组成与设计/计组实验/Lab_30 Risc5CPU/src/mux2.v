module mux2(in0, in1, addr, out);
	input [31:0] in0, in1; // 输入
	input addr; // 地址
	output [31:0] out; // 输出
	
	assign out = addr?in1:in0; // 根据地址选择
endmodule