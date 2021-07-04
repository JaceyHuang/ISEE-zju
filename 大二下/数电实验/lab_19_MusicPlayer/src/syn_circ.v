module syn_circ(in, clk, out);
	input in, clk; // 输入
	output out;
	reg q1, q2; // 两个触发器的输出
	
	always @ (posedge clk)
	begin 
		q1 <= in; // 非阻塞赋值
		q2 <= q1;	
	end
	assign out = q1 && (~q2);
endmodule