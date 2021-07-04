module note_player(clk, reset, play_enable, note_to_load, duration_to_load, load_new_note, note_done, sampling_pulse, beat, sample, sample_ready);
	input clk, reset;
	input play_enable; // 高电平表示播放
	input[5:0] note_to_load; // 需播放的音符
	input[5:0] duration_to_load; // 需播放音符的音长
	input load_new_note; // 新的音符需播放
	input sampling_pulse; // 索取新的正弦样品
	input beat; // 定时基准信号
	output note_done; // 音符播放完毕
	output[15:0] sample; // 正弦样品输出
	output sample_ready; // 下一个正弦信号
	
	wire[5:0] q; // FreqROM地址输入	
	wire[19:0] dout; // FreqROM输出
	wire timer_clear, timer_done; //音符定时器输入输出
	wire load; // D触发器使能输入
	
	// D触发器实例
	dffre #(.n(6)) d0(.d(note_to_load), .en(load), .r(reset || ~play_enable), .clk(clk), .q(q));
	
	// Frequency ROM，dout为DDS模块k的后20位
	frequency_rom rom0(.clk(clk), .dout(dout), .addr(q));
	
	// DDS实例
	dds dds0(.clk(clk), .reset(reset || ~play_enable), .sampling_pulse(sampling_pulse), .k({2'b00, dout}), .sample(sample), .new_sample_ready(sample_ready));

	// note_player控制器
	note_player_ctrl ctrl0(.clk(clk), .reset(reset), .play_enable(play_enable), .load_new_note(load_new_note), .load(load), .timer_clear(timer_clear), .timer_done(timer_done), .note_done(note_done));
	
	// 音符节拍定时器
	note_timer timer0(.clk(clk), .beat(beat), .duration_to_load(duration_to_load), .timer_clear(timer_clear), .timer_done(timer_done));
endmodule