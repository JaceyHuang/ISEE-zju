module music_player(clk_10m, reset, speaker);
	input clk_10m, reset;
	output speaker;
	
	wire[5:0] q; // 计时
	wire[3:0] high, med, low; // 音乐信息
	wire clk_4, clk_5m;
	
	// 地址计数器，得到当前乐符位置
	counter_n #(.n(63), .counter_bits(6)) cnt0(.clk(clk_4), .en(1), .r(reset), .q(q), .co());
	
	// 由10MHz分频得到5MHz时钟
	counter_n #(.n(2), .counter_bits(1)) cnt1(.clk(clk_10m), .en(1), .r(reset), .q(), .co(clk_5m));
	
	// 由5MHz分频得到4Hz时钟
	counter_n #(.n(1250000), .counter_bits(21)) cnt2(.clk(clk_5m), .en(1), .r(reset), .q(), .co(clk_4));
	
	// 只读存储器
	song_rom rom0(.clk(clk_4), .dout({high, med, low}), .addr(q));
	
	// 分频器及输出
	divider d0(.clk_5m(clk_5m), .clk_4(clk_4), .din({high, med, low}), .speaker(speaker));
	
endmodule