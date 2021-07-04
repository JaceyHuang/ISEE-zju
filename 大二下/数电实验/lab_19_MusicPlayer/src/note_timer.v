module note_timer(clk, beat, duration_to_load, timer_clear, timer_done);
	input clk;
	input beat; // 定时基准信号，频率为48Hz的脉冲(使能输入)
	input[5:0] duration_to_load; // 播放音符的音长
	input timer_clear; // 清0信号
	output timer_done; // 定时结束
	reg[5:0] cnt = 0; // 计数，因为音长为5bits(32)，故cnt长为5位
	
	assign timer_done = (cnt == (duration_to_load - 1)); // 定时结束
	
	always @ (posedge clk)
	begin
		if (timer_clear) cnt = 0; // 清0
		else 
		begin
			if (beat) cnt = cnt + 1;
			else cnt = cnt; // 若beat高电平则计数，否则保持
		end
	end
endmodule