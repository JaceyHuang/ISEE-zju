module counter_n(clk, en, r, co, q);
    parameter n = 8; // 计数的模(分频比)
	parameter counter_bits = 3; // 状态位数 
	input clk, en, r ;
	output reg co; // 进位输出
	output reg[counter_bits-1:0] q = 0;
  
	always @ (posedge clk) 
	begin
		co = (q==(n-1))&&en; //进位

        if (r) q = 0;
	    else if (en)  // 使能高电平计数
	    begin	 
		    if (q==(n-1)) q = 0 ; // 清0
		    else q = q + 1; // 计数
	    end
	    else q = q; // 否则保持
	end

endmodule