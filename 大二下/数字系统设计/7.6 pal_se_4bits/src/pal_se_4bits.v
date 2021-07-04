module pal_se_4bits(clk, reset, load, in, out);
	input clk, reset, load;
	input[3:0] in;
	output reg out;
	reg[3:0] buff; // 保存串行数据

	always @ (posedge clk)
	begin
		if (reset) buff = 4'b0; // 同步清零，高电平有效
		else if (load) buff = in; // 载入数据，高电平有效
		// 时钟上升沿输出一位
		out = buff[3];
		buff <= buff<<1; // 左移
	end
endmodule