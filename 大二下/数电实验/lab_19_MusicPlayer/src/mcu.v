module mcu (clk, reset, play_pause, next, song_done, play, reset_play, song);
	input clk, reset;
	input play_pause; // play_pause按钮
	input next; // next按钮
	input song_done; // 乐曲播放结束
	output play; 
	output reset_play; // 脉冲复位
	output[1:0] song; // 乐曲序号
	wire NextSong; // 控制器输出

	// 控制器实例
	mcu_ctrl ctrl0(.clk(clk), .reset(reset), .play_pause(play_pause), .next(next), .song_done(song_done), .play(play), .reset_play(reset_play), .NextSong(NextSong));
	
	// 2位二进制计数器实例
	counter_n #(.n(4), .counter_bits(2)) song_cnt(.clk(clk), .en(NextSong), .r(0), .q(song), .co()); 
endmodule