function quantizedSignal = signalquantization(Fs, sampledSignal, nQuantizationBits)
% SIGNALQUANTIZATION 输入语音信号的均匀量化
% 输入参数:
%    Fs: 采样频率
%    sampledSignal: 采样后的语音信号
%    nQuantizationBits: 量化位数
% 输出参数:
%    quantizedSignal: 量化后的语音信号

Min = min(sampledSignal); % 找出信号的最小值
Max = max(sampledSignal); % 找出信号的最大值
delta = (Max-Min)/2^nQuantizationBits; % 最小分辨率
for i = 1:2^nQuantizationBits+1
    q(i) = Min + delta*(i-1); % 量化取值
end

% 向上取整
N = length(sampledSignal); % 采样语音信号的每个点索引
quantizedSignal = sampledSignal;
for i = 1:N
    for j = 1:2^nQuantizationBits
        % 若信号某点取值在两个量化值之间，则取其量化值的中间值
        if sampledSignal(i)>=q(j) && sampledSignal(i)<=q(j+1)
            quantizedSignal(i) = (q(j)+q(j+1))/2;
            break
        end
    end
end

% 向下取整
N = length(sampledSignal); % 采样语音信号的每个点索引
quantizedSignalRoundDown = sampledSignal;
for i = 1:N
    for j = 1:2^nQuantizationBits+1
        % 若信号某点取值在量化值正负半个量化区间内，则取该量化值
        if sampledSignal(i)>=q(j)-0.5*delta && sampledSignal(i)<=q(j)+0.5*delta
            quantizedSignalRoundDown(i) = q(j);
            break
        end
    end
end

% % 比较量化前后的信号
% info = audioinfo('../data/command.flac'); % 采样所得语音信号的信息
% t = 0:seconds(1/Fs):seconds(info.Duration); % 语音经过的时间
% t = t(1:end-1);
% figure; subplot(2,1,1);
% plot(t, sampledSignal); % 绘制量化前信号的时域波形
% hold on; plot(t, quantizedSignal,'r'); % 绘制量化后信号的时域波形（向上取整）
% legend('量化前信号','量化后信号');
% title('量化前后信号对比(向上取整)'); xlabel('Time'); ylabel('Signal');
% subplot(2,1,2);
% plot(t, sampledSignal); % 绘制量化前信号的时域波形
% hold on; plot(t, quantizedSignalRoundDown,'r'); % 绘制量化后信号的时域波形（向下取整）
% legend('量化前信号','量化后信号');
% title('量化前后信号对比（向下取整）'); xlabel('Time'); ylabel('Signal');

end