module dffre(d, en, r, clk, q);
    input en, r, clk;
    input d; // 输入
    output reg q; // 输出

    always @ (posedge clk)
        if (r) // 清零
			q = 0;
        else if (en) // 使能正常工作
			q = d;
        else // 保持
			q = q;
endmodule
