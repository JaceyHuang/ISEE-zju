module counter_n(clk, en, r, q, co);
	parameter n = 2; // 计数的模(分频比)
	parameter counter_bits = 1; // 状态位数 
	input clk, en, r ;
	output co; // 进位输出
	output reg[counter_bits-1:0] q = 0;
  
	assign co = (q == (n-1)) && en; //进位
	
	always @(posedge clk) 
	begin
      if (r) q = 0;
	  else if(en)  // 使能高电平计数
	  begin	 
		if (q == (n-1)) q = 0 ; // 清0，实现循环播放
		else q = q + 1; // 计数
	  end
	  else q = q; // 否则保持
	end
endmodule
