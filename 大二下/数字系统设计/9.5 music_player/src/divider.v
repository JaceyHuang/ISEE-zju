module divider(clk_5m, clk_4, din, speaker);
	input clk_5m, clk_4;
	input[11:0] din; // 音乐信息
	output reg speaker = 0;
	
	reg[13:0] origin = 0, divide = 0; // 分频比
	reg carry = 0;
	
	always @ (posedge clk_5m) // 通过置数，改变分频比(carry)
	begin
		if (origin)
		begin
			if (divide == 16383)
			begin 
				carry = 1;
				divide = origin;
			end
			else
			begin
				divide = divide + 1;
				carry = 0;
			end
		end
		else divide = 0;
	end
	
	always @ (posedge carry) // 输出
	begin
		speaker = ~speaker;
	end
	
	always @ (posedge clk_4) // 频率
	begin
		case (din)
			'h001: origin <= 4915;
			'h002: origin <= 6168;
			'h003: origin <= 7281;
			'h004: origin <= 7792;
			'h005: origin <= 8730;
			'h006: origin <= 9565;
			'h007: origin <= 10310;
			'h010: origin <= 10647;
			'h020: origin <= 11272;
			'h030: origin <= 11831;
			'h040: origin <= 12094;
			'h050: origin <= 12556;
			'h060: origin <= 12974;
			'h070: origin <= 13346;
			'h100: origin <= 13516;
			'h200: origin <= 13829;
			'h300: origin <= 14109;
			'h400: origin <= 14235;
			'h500: origin <= 14470;
			'h600: origin <= 14678;
			'h700: origin <= 14864;
			'h000: origin <= 16383;
		endcase
	end
endmodule