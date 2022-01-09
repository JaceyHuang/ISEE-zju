% DFT.m
clc; clear;
T = 0.000625; N = 32; % 谱分析参数，每组在此处修改(此为第一组)
% T = 0.005; N = 32; % 第二组参数
% T = 0.0046875; N = 32; % 第三组参数
% T = 0.004; N = 32; % 第四组参数
% T = 0.0025; N = 16; % 第五组参数
t = 0:0.001:N*T; xt = sin(2*pi*50*t); % 原信号
n = 0:N-1; xn = sin(2*pi*50*n*T); % 抽样所得序列
k = 0:N-1; X = dftmtx(N)*xn'; % DFT

figure; % 时域图像对比
subplot(2,1,1); plot(t,xt); xlim([0 N*T]); % 原信号图像
xlabel('t'); ylabel('x(t)'); title('原信号');
subplot(2,1,2); stem(n,xn); xlim([0 N]); % 序列图像
xlabel('n'); ylabel('x(n)'); title('抽样所得序列');

figure; % 序列时域图形
subplot(2,2,1); stem(n,real(xn)); xlim([0 N]); % 序列实部
xlabel('n'); ylabel('Re\{x(n)\}'); title('序列实部');
subplot(2,2,2); stem(n,imag(xn)); xlim([0 N]); % 序列虚部
xlabel('n'); ylabel('Im\{x(n)\}'); title('序列虚部');
subplot(2,2,3); stem(n,abs(xn)); xlim([0 N]); % 序列的模
xlabel('n'); ylabel('|x(n)|'); title('序列模长');
subplot(2,2,4); stem(n,180/pi*angle(xn)); xlim([0 N]); % 序列相角
xlabel('n'); ylabel('\phi'); title('序列相角');

figure; % 序列频谱
subplot(4,1,1); stem(k,X); xlim([0 N]); % DFT频谱
xlabel('k'); ylabel('X'); title('频谱');
subplot(4,1,2); stem(k,abs(X)); xlim([0 N]); % 幅度谱
xlabel('k'); ylabel('|X|'); title('幅度谱');
max_value = roundn(max(abs(X)),-4); % 最大值
max_index = find(roundn(abs(X),-4)==max_value); % 寻找最大值的索引
index = max_index(1); % 取第一个最大值的索引
format = sprintf('(%d, %.2f)',(index-1),max_value); % 第一个峰的坐标
text((index-1),max_value,format); % 在图形上显示
subplot(4,1,3); stem(k,real(X)); xlim([0 N]); % 频谱实部
xlabel('k'); ylabel('Re\{X\}'); title('频谱实部');
subplot(4,1,4); stem(k,imag(X)); xlim([0 N]); % 频谱虚部
xlabel('k'); ylabel('Im\{X\}'); title('频谱虚部');