module mux4_1(in0, in1, in2, in3, sel, out);
	input in0, in1, in2, in3;
	input[1:0] sel; // 选择信号
	output out;
	
	// 根据选择信号的值选出对应输入作为输出
	assign out = (sel == 0) ? in0 : (sel == 1) ? in1 : (sel ==2)? in2 : in3;
endmodule