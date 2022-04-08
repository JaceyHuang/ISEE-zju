% RemoteVoiceControlSys.m
% REMOTE VOICE CONTROL SYSTEM 远程声控系统的主函数，控制整个运行流程

clc; clear

%% 参数设置
% 采样
Fs = 44100; % 采样频率为44.1kHz
nSamplingBits = 16; % 采样位数为16位
nChannels = 1; % 单声道
% 量化
nQuantizationBits = 8; % 量化位数为8位
% 信道编码
n = 15; % 每组的编码长度
k = 7; % 每组的信息位长度
% 信道传输
SNR = 20; % 信噪比(dB)
SNRs = -10:30;

%% 系统实现
% 语音信号的采样
sampledSignal = signalsampling(Fs, nSamplingBits, nChannels);

% 语音信号的量化
quantizedSignal = signalquantization(Fs, sampledSignal, nQuantizationBits);

% 信源编码--Huffman编码
[sourceCodes, dict, K] = sourceencode(quantizedSignal, nQuantizationBits);

% 信道编码--(15,7)BCH码
channelCodes = channelencode(sourceCodes, n, k);

% 调制--BPSK
modulatedCodes = modulation(channelCodes);

% 信道传输--AWGN
transmittedCodes = channeltransmission(modulatedCodes, SNR);

% 解调
demodulatedCodes = demodulation(transmittedCodes, channelCodes);

% 信道解码
channelDecodes = channeldecode(demodulatedCodes, n, k, sourceCodes);

% 信源解码
sourceDecodes = sourcedecode(channelDecodes, dict, quantizedSignal, sampledSignal, Fs);

% 语音识别
signal = speechrecognition(sourceDecodes, Fs);

% sound(sampledSignal);

% % 信噪比与误码率关系验证
% numerrs = zeros(length(SNRs),1);
% ratio = zeros(length(SNRs),1);
% for i = 1:length(SNRs)
%     transmittedCodes = channeltransmission(modulatedCodes, SNRs(i)); % 信道传输
%     demodulatedCodes = demodulation(transmittedCodes, channelCodes); % 解调
%     channelDecodes = channeldecode(demodulatedCodes, n, k, sourceCodes); % 信道解码
%     [numerrs(i), ratio(i)] = biterr(channelDecodes, sourceCodes); % 计算误码数和误码率
% end
% % 绘图
% plot(SNRs, ratio); title('不同信噪比下信道编码误码率');
% xlabel('SNR(dB)'); ylabel('误码率');