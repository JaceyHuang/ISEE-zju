module JK_trigger(clk, J, K, q, qn);
	input J, K, clk; // 输入
	output reg q;
	output wire qn; // 输出

	always @ (posedge clk)
	begin
		if (J == 1 && K == 1) q = ~q; // 翻转
		else if (J == 1 && K == 0) q = 1; // 置1
		else if (J == 0 && K == 1) q = 0; // 置0
		else q = q; // 保持
	end		
	assign qn = ~q;
endmodule 