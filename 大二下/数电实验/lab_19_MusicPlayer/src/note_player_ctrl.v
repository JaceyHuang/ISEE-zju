module note_player_ctrl(clk, reset, play_enable, load_new_note, load, timer_clear, timer_done, note_done);
	input clk, reset;
	input play_enable; // 来自mcu的play信号，高电平表示播放
	input load_new_note; // 来自song_reader的new_note信号，表示新的音符需要播放
	input timer_done; // 定时结束标志
	output reg load; // D触发器的使能输入
	output reg timer_clear; // 清0信号
	output reg note_done; // 给song_reader的应答信号，表示音符播放完毕
	
	parameter RESET = 0, WAIT = 1, DONE = 2, LOAD = 3; // 状态编码
	reg[1:0] state, nextstate;
	
	always @ (posedge clk)
	begin
		if (reset) state = RESET; // 若复位，则处于RESET状态
		else state = nextstate;
	end
	
	always @ (*)
	begin
		timer_clear = 0; load = 0; note_done = 0; // 初始化
		case (state)
			RESET: begin timer_clear = 1; nextstate = WAIT; end // RESET状态
			WAIT: begin
					if (play_enable) 
					begin
						if (timer_done) nextstate = DONE; // 定时结束
						else 
						begin
							if (load_new_note) nextstate = LOAD; // 读取新的音符
							else nextstate = WAIT;
						end
					end
					else nextstate = RESET;
				  end
			DONE: begin // 音符播放完毕
					timer_clear = 1; note_done = 1;
					nextstate = WAIT;
				  end
			LOAD: begin // 读取新的音符
					timer_clear = 1; load = 1;
					nextstate = WAIT;
				  end
			default: nextstate = RESET; // 否则处于RESET状态
		endcase
	end
endmodule