% sine_seq.m
clc;
clear;

% x(n)=sin(0.2*pi*n)，序列长度为10
length = 10;
n = 0:length-1;
x = sin(2*pi*0.1.*n);
k = 0:length-1;
y = dftmtx(10)*x'; % DFT
figure; % 绘图
% 此序列的实部
subplot(2,2,1);stem(n,real(x));xlabel('n');ylabel('Re\{x(n)\}');title('实部');  
% 此序列的虚部
subplot(2,2,2);stem(n,imag(x));xlabel('n');ylabel('Im\{x(n)\}');title('虚部');
% 此序列的模与相角
subplot(2,2,3);stem(n,abs(x));xlabel('n');ylabel('|x(n)|');title('模'); 
subplot(2,2,4);stem(n,(180/pi)*angle(x)); % 将弧度转为角度
xlabel('n');ylabel('\phi');title('相角');
figure;
% 幅度谱
subplot(3,1,1);stem(k,abs(y));xlabel('k');ylabel('|y|');title('幅度谱');
% 频谱实部
subplot(3,1,2);stem(k,real(y));xlabel('k');ylabel('Re\{y\}');title('频谱实部');
% 频谱虚部
subplot(3,1,3);stem(k,imag(y));xlabel('k');ylabel('Im\{y\}');title('频谱虚部');