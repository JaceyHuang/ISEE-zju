module light(clk, reset, q);
	input clk, reset;
	output reg[7:0] q;  // 控制花灯，某一位为1，则对应花灯亮起
	reg[3:0] state;
	parameter s0 = 4'b0000,
			  s1 = 4'b0001,
			  s2 = 4'b0011,
			  s3 = 4'b0010,
			  s4 = 4'b0110,
			  s5 = 4'b0111,
			  s6 = 4'b0101,
			  s7 = 4'b0100,
			  s8 = 4'b1100,
			  s9 = 4'b1101,
			  s10 = 4'b1111,
			  s11 = 4'b1110; // 状态编码

	always @ (posedge clk)
	begin
		if (reset) 
		begin
			q = 8'b0; // 同步清零，高电平有效
			state = s0;
		end
		else 
		begin
			case (state)
				s0: begin state = s1; q = 8'h0; end // 8路彩灯同时亮灭
				s1: begin state = s2; q = 8'hff; end
				s2: begin state = s3; q = 8'h01; end // 从左至右逐个亮起
				s3: begin state = s4; q = 8'h02; end
				s4: begin state = s5; q = 8'h04; end
				s5: begin state = s6; q = 8'h08; end
				s6: begin state = s7; q = 8'h10; end
				s7: begin state = s8; q = 8'h20; end
				s8: begin state = s9; q = 8'h40; end
				s9: begin state = s10; q = 8'h80; end
				s10: begin state = s11; q = 8'b01010101; end // 4亮4灭
				s11: begin state = s0; q = 8'b10101010; end
				default: begin state = s0; q = 8'b0; end
			endcase
		end
	end
endmodule