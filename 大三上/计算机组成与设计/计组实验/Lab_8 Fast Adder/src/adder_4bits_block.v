module adder_4bits_block(a, b, ci, s, co);
	input [3:0] a, b; // 输入的四位二进制数
	input ci; // 低位进位
	output [3:0] s; // 计算的和
	output co; // 输出进位
	wire [3:0] s0, s1; // 保存两个加法器的计算结果
	wire c0, c1; // 保存两个加法器的进位
	
	adder_4bits a0(.a(a), .b(b), .ci(0), .s(s0), .co(c0)); // 进位输入为0
	adder_4bits a1(.a(a), .b(b), .ci(1), .s(s1), .co(c1)); // 进位输入为1
	mux m(.in0(s0), .in1(s1), .addr(ci), .out(s)); // 根据低位进位选择输出
	assign co = (ci & c1) | c0; // 进位输出
endmodule