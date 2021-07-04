module JK_trigger(clk, J, K, q, qn);
	input J, K, clk; // 输入
	output q, qn; // 输出
	wire clk_0, x1, y1, q1, q1n, x2, y2;

	nand(x1, J, qn, clk);
	nand(y1, K, q, clk);
	not(clk_0, clk);
	nand(q1, x1, q1n);
	nand(q1n, y1, q1);
	nand(x2, q1, clk_0);
	nand(y2, q1n, clk_0);
	nand(q, x2, qn);
	nand(qn, y2, q);
endmodule