module shift_reg_4bits(clk, reset, in, out);
	input clk, reset, in;
	output reg[3:0] out = 4'b0;

	always @ (posedge clk) 
	begin
		if (reset) out = 4'b0; // 同步清零，高电平有效
		else 
		begin
			out <= out<<1; // 输出信号左移一位(并行输出)
			out[0] <= in; // 输入信号补充到最低位
		end
	end
endmodule