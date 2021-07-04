module counter_8bits(clk, reset, q);
	  input clk, reset;
	  output reg [7:0] q;
	  
	  always @ (posedge clk) // 时钟上升沿触发
	  begin
		if (reset == 1) q = 8'b0; // 同步复位
		else 
		begin
		  if (q == 8'hff) q = 0; // 溢出则清0
		else q = q + 1; // 计数
		end
	  end
endmodule