module pipeline_adder(clk, a, b, ci, s, co);
	input clk; // 时钟
	input [31:0] a, b; // 输入的32位数
	input ci; // 输入进位
	output reg [31:0] s; // 输出结果（第4级锁存）
	output reg co; // 输出进位
	
	reg [31:0] tmpa0, tmpb0; // 第0级锁存a、b 
	reg tmpci; // 第0级锁存ci
	
	reg [7:0] sum0; // 第1级加法结果
	reg tmpc0; // 第1级加法进位
	reg [23:0] tmpa1, tmpb1; // 第1级锁存a、b的前24位
	
	reg [15:0] sum1; // 前2级加法结果
	reg tmpc1; // 第2级加法进位
	reg [15:0] tmpa2, tmpb2; // 第2级锁存a、b的前16位
	
	reg [23:0] sum2; // 前3级加法结果
	reg tmpc2; // 第3级加法进位
	reg [7:0] tmpa3, tmpb3; // 第3级锁存a、b的前8位
	
	always @ (posedge clk)
	begin 
		tmpa0 <= a;
		tmpb0 <= b;
		tmpci <= ci;  // 锁存a、b、ci
	end
	
	// 第1级锁存
	always @ (posedge clk)
	begin
		{tmpc0, sum0} <= 9'b0 + tmpa0[7:0] + tmpb0[7:0] + tmpci; // 计算低8位和及进位
		tmpa1 <= tmpa0[31:8];
		tmpb1 <= tmpb0[31:8]; // 锁存a、b的前24位
	end

	// 第2级锁存
	always @ (posedge clk)
	begin
		{tmpc1, sum1} <= {9'b0 + tmpa1[7:0] + tmpb1[7:0] + tmpc0, sum0};  // 低16位的和及其进位
		tmpa2 <= tmpa1[23:8];
		tmpb2 <= tmpb1[23:8]; // 锁存a、b的前16位
	end
	
	// 第3级锁存
	always @ (posedge clk)
	begin
		{tmpc2, sum2} <= {9'b0 + tmpa2[7:0] + tmpb2[7:0] + tmpc1, sum1}; // 低24位的和及其进位
		tmpa3 <= tmpa2[15:8];
		tmpb3 <= tmpb2[15:8]; // 锁存a、b的前8位
	end
	
	// 第4级锁存
	always @ (posedge clk)
	begin
		{co, s} <= {9'b0 + tmpa3[7:0] +tmpb3[7:0] + tmpc2, sum2}; // 最终求和结果
	end
endmodule