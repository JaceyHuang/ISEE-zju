% BP_FIR.m
clc; clear;

fl = 160-150/2; % 通带开始频率
fh = 1500+150/2; % 通带截止频率
% 读取音频信息，fs为采样频率
[audio,fs] = audioread('../Audio/05-03-noisy.wav');
Y=fft(audio); % 原始信号的频谱 
N = length(audio); % 信号长度
wl = 2*pi*fl/fs;
wh = 2*pi*fh/fs; % 数字截止频率
tr_width = 2*pi*150/fs; % 过渡带宽 

% 矩形窗
N1 = ceil(1.8*pi/tr_width)+1; % 取奇数97
w_rec = (rectwin(N1))'; % 窗函数
h1 = fir1(N1-1,[wl/pi,wh/pi],'BANDPASS',w_rec); % h1(n)
[H1,db1,mag1,pha1,grd1,w1] = freqz_m(h1,1);
y1 = filter(h1,1,audio); % 滤波
Y1 = fft(y1); % 频谱

% 汉宁窗
N2 = ceil(6.2*pi/tr_width); 
w_han = (hanning(N2))'; % 窗函数
h2 = fir1(N2-1,[wl/pi,wh/pi],'BANDPASS',w_han); % h2(n)
[H2,db2,mag2,pha2,grd2,w2] = freqz_m(h2,1);
y2 = filter(h2,1,audio); % 滤波
Y2 = fft(y2); % 频谱

% 绘图
figure; 
subplot(2,1,1); plot(0:1/fs:(N-1)/fs,audio); title('原始信号时域序列');
xlabel('t/s'); ylabel('magnitude'); xlim([0 (N-1)/fs]);
subplot(2,1,2); plot(0:fs/(N-1):fs,abs(Y)); title('原始信号频谱'); 
xlabel('frequency/Hz'); ylabel('magnitude'); xlim([0 fs]);

figure; % 滤波器的幅频响应
subplot(2,1,1); plot(0:1/500:1,20*log10(mag1)); title('20lg|H1(w)|'); % H1(w)
xlabel('frequency in pi units'); ylabel('Decibles');
subplot(2,1,2); plot(0:1/500:1,20*log10(mag2)); title('20lg|H2(w)|'); % H2(w)
xlabel('frequency in pi units'); ylabel('Decibles');

figure; % 滤波后的时域序列
subplot(2,1,1); plot(0:1/fs:(N-1)/fs,y1); title('矩形窗输出时域序列'); % 矩形窗
xlabel('t/s'); ylabel('magnitude'); xlim([0 (N-1)/fs]);
subplot(2,1,2); plot(0:1/fs:(N-1)/fs,y2); title('汉宁窗输出时域序列'); % 汉宁窗
xlabel('t/s'); ylabel('magnitude'); xlim([0 (N-1)/fs]);

figure; % 滤波后的频谱
subplot(2,1,1); plot(0:fs/(N-1):fs,abs(Y1)); title('矩形窗输出频谱'); % 矩形窗
xlabel('frequency/Hz'); ylabel('magnitude'); xlim([0 fs]);
subplot(2,1,2); plot(0:fs/(N-1):fs,abs(Y2)); title('汉宁窗输出频谱'); % 汉宁窗
xlabel('frequency/Hz'); ylabel('magnitude'); xlim([0 fs]);

% 写入音频文件
audiowrite('../Audio/rectwin.wav',y1,fs);
audiowrite('../Audio/hanning.wav',y2,fs);
