% Filters.m
clc; clear;

N1 = 200; % 长度
n1 = 0:N1-1;
x = rand(1,N1)-0.5; % 随机信号序列
X = dftmtx(N1)*x'; % 幅度谱

wc = 0.5*pi; % 截止频率
N2 = 31; % 窗长
n2 = 0:N2-1;
w1 = (rectwin(N2))'; % 矩形窗
w2 = (hamming(N2))'; % 汉明窗

N3 = 127; % 窗长
n3 = 0:N3-1;
w3 = (rectwin(N3))'; % 矩形窗

% 第一个滤波器的单位抽样响应序列
h1 = fir1(N2-1,wc/pi,w1);
% 第二个滤波器的单位抽样响应序列
h2 = fir1(N2-1,wc/pi,w2);
% 第三个滤波器的单位抽样响应序列
h3 = fir1(N3-1,wc/pi,w3); 

% 经过第一个滤波器后的输出序列
y1 = filter(h1,1,x);
Y1 = dftmtx(N1)*y1'; % 幅度谱
% 经过第二个滤波器后的输出序列
y2 = filter(h2,1,x);
Y2 = dftmtx(N1)*y2'; % 幅度谱
% 经过第三个滤波器后的输出序列
y3 = filter(h3,1,x);
Y3 = dftmtx(N1)*y3'; % 幅度谱

% 第一个滤波器的频率响应
[H1,db1,mag1,pha1,grd1,w1] = freqz_m(h1,1);
% 第三个滤波器的频率响应
[H3,db3,mag3,pha3,grd3,w3] = freqz_m(h3,1);

% 将X(k)写入文件
f1 = fopen('../MATLAB计算结果/randomSeq.txt','w');
for i = 1:N1
    fprintf(f1,'X(%d) = %.5f\n',i-1,X(i));
end

% 绘图
subplot(2,1,1); stem(n1,x,'filled');
title('信号序列x(n)'); xlabel('n'); ylabel('magnitude');
subplot(2,1,2); stem(n1,abs(X),'filled');
title('幅度谱|X(k)|'); xlabel('k'); ylabel('magnitude');

figure; % 第一个滤波器
subplot(2,1,1); stem(n1,abs(X),'filled');
title('|X(k)|'); xlabel('k'); ylabel('magnitude');
subplot(2,1,2); stem(n1,abs(Y1),'filled');
title('|Y1(k)|'); xlabel('k'); ylabel('magnitude');

figure; % 第二个滤波器
subplot(2,1,1); stem(n1,abs(X),'filled');
title('|X(k)|'); xlabel('k'); ylabel('magnitude');
subplot(2,1,2); stem(n1,abs(Y2),'filled');
title('|Y2(k)|'); xlabel('k'); ylabel('magnitude');

figure; % 第三个滤波器
subplot(2,1,1); stem(n1,abs(X),'filled');
title('|X(k)|'); xlabel('k'); ylabel('magnitude');
subplot(2,1,2); stem(n1,abs(Y3),'filled');
title('|Y3(k)|'); xlabel('k'); ylabel('magnitude');

% 比较滤波器输出频谱
figure; stem(n1,abs(Y1),'filled');
hold on; stem(n1,abs(Y2),':p','filled');
title('输出频谱'); xlabel('k'); ylabel('magnitude');
legend('|Y1(k)|','|Y2(k)|'); % |Y1(k)|与|Y2(k)|

figure; stem(n1,abs(Y1),'filled');
hold on; stem(n1,abs(Y3),':p','filled');
title('输出频谱'); xlabel('k'); ylabel('magnitude');
legend('|Y1(k)|','|Y3(k)|'); % |Y1(k)|与|Y3(k)|

% 比较滤波器性能
figure; 
subplot(2,1,1); plot(0:1/500:1,mag1); 
hold on; plot(0:1/500:1,mag3,'-r');
title('频谱'); xlabel('frequency in pi units'); ylabel('magnitude');
legend('|H1(w)|','|H3(w)|'); % |H1(w)|与|H3(w)|
subplot(2,1,2); plot(0:1/500:1,20*log10(mag1)); 
hold on; plot(0:1/500:1,20*log10(mag3),'-r');
title('频率响应'); xlabel('frequency in pi units'); ylabel('dB');
legend('20lg|H1(w)|','20lg|H3(w)|'); % 幅频响应