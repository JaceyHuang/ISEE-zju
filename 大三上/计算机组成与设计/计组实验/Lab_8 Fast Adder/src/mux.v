module mux(in0, in1, addr, out);
	input [3:0] in0, in1; // 输入数据
	input addr; // 地址
	output [3:0] out; // 选择输出

	assign out[3:0] = (addr == 0) ? in0[3:0] : in1[3:0];
endmodule