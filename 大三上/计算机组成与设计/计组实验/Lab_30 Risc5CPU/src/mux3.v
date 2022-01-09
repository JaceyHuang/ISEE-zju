module mux3(in0, in1, in2, addr, out);
	input [31:0] in0, in1, in2; // 输入
	input [1:0] addr; // 地址
	output reg [31:0] out; // 输出
	
	always @ (*)
	begin
		case (addr)
			2'b00: out = in0;
			2'b01: out = in1;
			2'b10: out = in2;
			default: out = in0;
		endcase
	end
endmodule