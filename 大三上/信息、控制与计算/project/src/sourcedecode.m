function sourceDecodes = sourcedecode(channelDecodes, dict, quantizedSignal, sampledSignal, Fs)
% SOURCEDECODE 信源解码，采用二元Huffman编码
% 输入参数：
%    channelDecodes: 信道解码后的序列 
%    dict: 信源编码得到的码书
%    quantizedSignal: 量化后的信号
%    sampledSignal: 采样后的信号
%    Fs: 采样频率
% 输出参数：
%    sourceCodes: 信源解码后的字符序列

% 信源解码
sourceDecodes = huffmandeco(channelDecodes, dict);

% sound(sourceDecodes); % 播放信源解码后的信号

% rights = length(find(sourceDecodes==quantizedSignal)); % 计算错误数和错误率
% numerrs = length(quantizedSignal)-rights; % 错误数
% ratio = numerrs/length(quantizedSignal); % 错误率

% % 信号的时域和频域对比
% % 时域
% info = audioinfo('../data/command.flac'); % 采样所得语音信号的信息
% t = 0:seconds(1/Fs):seconds(info.Duration); % 语音经过的时间
% t = t(1:end-1); figure;
% subplot(2,1,1); plot(t, sampledSignal); % 绘制采样后的信号
% hold on; plot(t, sourceDecodes, 'r'); % 绘制信源解码得到的信号
% legend('采样后信号','信源解码后信号');
% title('信源解码信号与采样后信号的时域对比'); xlabel('Time'); ylabel('Signal');
% % 频域
% N1 = length(sampledSignal); % 信号点数
% N2 = length(sourceDecodes);
% X1 = fft(sampledSignal); % 对信号进行傅里叶变换
% X2 = fft(sourceDecodes);
% f1 = Fs/N1*(0:round(N1/2)-1); % 显示实际频域的一半，单位为Hz
% f2 = Fs/N2*(0:round(N2/2)-1);
% subplot(2,1,2); plot(f1, abs(X1(1:round(N1/2)))); % 绘制频域图像
% hold on; plot(f2, abs(X2(1:round(N2/2))), 'r');
% legend('采样后信号','信源解码后信号');
% title('信源解码信号与采样后信号的频域对比'); xlabel('Frequency/Hz'); ylabel('Amplitude');
% xlim([0 Fs/2]); 

% % 将数据写入文件
% fp = fopen('../data/SourceDecode.txt','w');
% fprintf(fp, '错误数: %d\n', numerrs);
% fprintf(fp, '错误率: %f\n', ratio);
% fprintf(fp, '\n');
% fprintf(fp, '信源解码结果: \n');
% for i = 1:length(sourceDecodes)
%     fprintf(fp, '%d\n', sourceDecodes(i)); % 信源解码结果
% end

end