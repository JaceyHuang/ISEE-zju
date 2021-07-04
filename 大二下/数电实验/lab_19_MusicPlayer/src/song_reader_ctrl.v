module song_reader_ctrl(clk, reset, note_done, play, new_note);
	input clk, reset;
	input note_done; // 音符播放结束
	input play; // 高电平要求播放
	output  reg new_note; // 新的音符需要播放
	
	parameter RESET = 0, NEW_NOTE = 1, WAIT = 2, NEXT_NOTE = 3; // 状态编码
	reg[1:0] state, nextstate;
	
	always @ (posedge clk)
	begin
		if (reset) state = RESET; // 若复位，则系统处于RESET状态
		else state = nextstate;
	end
	
	always @ (*)
	begin
		new_note = 0;
		case (state)
			RESET: begin // 处于RESET状态
					if(play) nextstate = NEW_NOTE;
					else nextstate = RESET;
				   end
			NEW_NOTE: begin // 处于NEW_NOTE状态
						new_note = 1;
						nextstate = WAIT;
					  end
			WAIT: begin // 若继续播放且乐符已播完，则NEXT_NOTE
					if (play) 
					begin
						if (note_done) nextstate = NEXT_NOTE;
						else nextstate = WAIT;
					end
					else nextstate = RESET;
				  end
			NEXT_NOTE: nextstate = NEW_NOTE; // 准备播放下一个音符
			default: nextstate = RESET;
		endcase
	end
endmodule