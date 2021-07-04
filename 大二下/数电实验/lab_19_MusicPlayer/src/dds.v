module dds (clk, reset, sampling_pulse, k, sample, new_sample_ready);
	input clk, reset, sampling_pulse;
	input[21:0] k;  // 相位增量
	output[15:0] sample;  // 正弦信号
	output new_sample_ready;
	
	// 中间变量
	wire[21:0] raw_addr;  // 地址处理输入
	wire[9:0] rom_addr;   // 地址处理输出
	wire[15:0] raw_data, data;  // 数据处理
	wire[21:0] sum;  // 加法器结果
	wire area;   // 区域

	// 加法器实例
	full_adder adder0(.a(k), .b(raw_addr), .s(sum), .co()); // 进位输出空脚
	
	// D触发器实例
	dffre #(.n(22)) dff0(.d(sum), .en(sampling_pulse), .r(reset), .clk(clk), .q(raw_addr)); // 产生raw_addr
	dffre #(.n(1)) dff1(.d(raw_addr[21]), .en(1), .r(0), .clk(clk), .q(area));  // 产生area
	dffre #(.n(16)) dff2(.d(data), .en(sampling_pulse), .r(0), .clk(clk), .q(sample));  // 产生正弦信号
	dffre #(.n(1)) dff3(.d(sampling_pulse), .en(1), .r(0), .clk(clk), .q(new_sample_ready));
	
	// 地址处理
	assign rom_addr[9:0] = raw_addr[20] ? ((raw_addr[20:10] == 1024) ? 1023 : (~raw_addr[19:10]+1)) : raw_addr[19:10];
	
	// 正弦查找表
	sine_rom rom0(.clk(clk), .addr(rom_addr), .dout(raw_data));
	
	// 数据处理
	assign data[15:0] = area ? (~raw_data[15:0]+1) : raw_data[15:0];
endmodule