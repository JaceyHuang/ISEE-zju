function [sampledSignal, fs] = signalsampling(Fs, nSamplingBits, nChannels)
% SIGNALSAMPLING 输入语音信号的采样
% 输入参数:
%    Fs: 采样频率
%    nSamplingBits: 采样位数
%    nChannels: 声道数
% 输出参数:
%    sampledSignal: 采样后的语音信号

% myRecording = audiorecorder(Fs, nSamplingBits, nChannels);
% disp('Start speaking.');
% recordblocking(myRecording, 1); % 录制时长为1s
% disp('End of Recording');
% play(myRecording); % 播放录制的音频
% sampledSignal = getaudiodata(myRecording); % 获取录音数据
% plot(sampledSignal); % 绘制语音信号
% audiowrite('../data/command.flac', sampledSignal, Fs); % 存储语音信号

[sampledSignal, fs] = audioread('../data/command.flac'); % 读取语音信号
info = audioinfo('../data/command.flac'); % 语音信号的信息
% plot(sampledSignal); % 绘制语音信号
% sound(sampledSignal); % 播放语音信号

% % 时域图像
% t = 0:seconds(1/Fs):seconds(info.Duration); % 语音经过的时间
% t = t(1:end-1);
% figure; subplot(2,1,1);
% plot(t, sampledSignal); % 绘制时域波形
% xlabel('Time'); ylabel('Sampled Signal');
% title('语音信号时域波形');

% % 频域图像
% N = length(sampledSignal); % 信号点数
% X = fft(sampledSignal); % 对语音信号进行傅里叶变换
% f = Fs/N*(0:round(N/2)-1); % 显示实际频域的一半，单位为Hz
% subplot(2,1,2);
% plot(f, abs(X(1:round(N/2)))); % 绘制频域图像
% xlabel('Frequency/Hz'); ylabel('Amplitude');
% xlim([0 Fs/2]); title('语音信号频谱');

end
