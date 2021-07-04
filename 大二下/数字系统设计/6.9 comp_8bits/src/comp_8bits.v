module comp_8bits(in, out);
	input[7:0] in;
	output[7:0] out;
	
	// 根据首位判断处理方式，若首位为0，则补码等于原码，否则除首位外求反再加1
	assign out = (in[7] == 1'b0) ? in : {in[7], (~in[6:0] + 1)};
endmodule