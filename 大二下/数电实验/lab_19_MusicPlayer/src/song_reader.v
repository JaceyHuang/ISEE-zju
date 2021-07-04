module song_reader(clk, reset, play, song, note_done, song_done, note, duration, new_note);
	input clk, reset;
	input play; // 来自mcu的控制信号，高电平要求播放
	input note_done; // 模块note_player的应答信号，表示音符播放结束
	input[1:0] song; // 当前播放乐曲的序号
	output song_done; // 乐曲播放结束
	output new_note; // 表示新的音符需播放
	output[5:0] note; // 音符标记
	output[5:0] duration; // 音符持续时间
	
	wire[4:0] q; // 乐曲音符地址
	wire co; // 地址计数器进位
	
	// 地址计数器(5bits)
	counter_n #(.n(32), .counter_bits(5)) addr_cnt(.clk(clk), .en(note_done), .r(reset), .q(q), .co(co));
	
	// 只读存储器
	song_rom rom0(.clk(clk), .dout({note, duration}), .addr({song, q}));
	
	// 结束判断
	song_over over0(.clk(clk), .ci(co), .din(duration), .dout(song_done));
	
	// 控制器
	song_reader_ctrl ctrl0(.clk(clk), .reset(reset), .note_done(note_done), .play(play), .new_note(new_note));
endmodule