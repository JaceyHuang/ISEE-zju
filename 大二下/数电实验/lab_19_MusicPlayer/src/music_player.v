module music_player(clk, reset, play_pause, next, NewFrame, sample, play, song);
	input clk, reset; // 高电平有效
	input play_pause; // 播放/暂停
	input next; // 下一首输入
	input NewFrame; // 高电平非同步脉冲，索取新的样品
	output[15:0] sample; // 正弦样品输出
	output play; // 播放状态指示
	output[1:0] song; // 曲号指示
	
	wire reset_play; // mcu复位模块输出
	wire song_done, new_note; // song_reader输出信号
	wire[5:0] note, duration; // 音符标记及持续时间
	wire note_done, sample_ready; // note_player输出信号
	wire ready; // 同步化电路输出
	wire beat; // 节拍基准产生器输出
	
	parameter sim = 0;
	
	// 主控制器mcu实例
	mcu m0(.clk(clk), .reset(reset), .play_pause(play_pause), .next(next), .song_done(song_done), .play(play), .reset_play(reset_play), .song(song));
	
	// 乐曲读取song_reader实例
	song_reader s0(.clk(clk), .reset(reset_play), .play(play), .song(song), .note_done(note_done), .song_done(song_done), .note(note), .duration(duration), .new_note(new_note));
	
	// 音符播放note_player实例
	note_player n0(.clk(clk), .reset(reset_play), .play_enable(play), .note_to_load(note), .duration_to_load(duration), .load_new_note(new_note), .note_done(note_done), .sampling_pulse(ready), .beat(beat), .sample(sample), .sample_ready(sample_ready));
	
	// 同步化电路syn_circ实例
	syn_circ syn0(.in(NewFrame), .clk(clk), .out(ready));
	
	// 节拍基准产生器实例，根据sim的值选择对应模式
	counter_n #(.n(sim ? 64 : 1000), .counter_bits(sim ? 6 : 10)) c0(.clk(clk), .en(ready), .r(0), .q(), .co(beat));
endmodule