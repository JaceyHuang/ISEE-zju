module seq1101(clk, reset, in, out);
	input clk, reset, in;
	output reg out;
	reg[2:0] state;
	parameter s0 = 3'b000, 
			  s1 = 3'b001, 
			  s2 = 3'b011, 
			  s3 = 3'b010, 
			  s4 = 3'b110; // 状态编码

	always @ (posedge clk)
	begin
		if (reset) // 同步复位，s0为起始状态，输出为0
		begin
			state = s0;
			out = 0;
		end
		else 
		begin
			case (state)
				s0: begin if (in) state = s1;
						  else state = s0; end // 检测到第一个'1'
				s1: begin if (in) state = s2;
						  else state = s0; end // 检测到第二个'1'
				s2: begin if (!in) state = s3; // 检测到'0'
						  else state = s2; end // 否则检测到'1'，返回s2
				s3: begin if (in) state = s4;
						  else state = s0; end // 检测到第三个'1'，即检测到该序列
				s4: begin if (in) state = s2;
						  else state = s0; end // 新的开始
				default: state = s0;
			endcase
		end
	end
	always @ (*)
	begin
		case (state)
			s4: out = 1;
			default: out = 0;
		endcase
	end
endmodule