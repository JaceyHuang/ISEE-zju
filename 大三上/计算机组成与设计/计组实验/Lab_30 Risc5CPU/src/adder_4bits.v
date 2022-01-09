module adder_4bits(a, b, ci, s, co);
	input [3:0] a, b; // 输入的四位二进制数
	input ci; // 最低位进位
	output [3:0] s; // 计算的和
	output co; // 进位输出
	wire [2:0] c; // 各级进位
	wire [3:0] p, g; // 辅助变量
	
	// 计算辅助变量
	assign g = a & b;
	assign p = a | b;
	
	// 计算各级进位
	assign c[0] = g[0]|(p[0]&ci);
	assign c[1] = g[1]|(p[1]&c[0]);
	assign c[2] = g[2]|(p[2]&c[1]);
	assign co = g[3]|(p[3]&c[2]);
	
	// 计算求和
	assign s[0] = (p[0]&~g[0])^ci;
	assign s[1] = (p[1]&~g[1])^c[0];
	assign s[2] = (p[2]&~g[2])^c[1];
	assign s[3] = (p[3]&~g[3])^c[2];
endmodule