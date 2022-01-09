% compound_seq.m
clc;
clear;

% x(n)=sin(0.2*pi*n)+0.5sin(0.6*pi*n)，序列长度为10
length1 = 10;
n1 = 0:length1-1;
x1 = sin(2*pi*0.1.*n1)+0.5*sin(2*pi*3*0.1.*n1);
k1 = 0:length1-1;
y1 = dftmtx(10)*x1'; % DFT
figure; % 绘图
% 此序列的实部
subplot(2,2,1);stem(n1,real(x1));xlabel('n');ylabel('Re\{x(n)\}');title('实部');  
% 此序列的虚部
subplot(2,2,2);stem(n1,imag(x1));xlabel('n');ylabel('Im\{x(n)\}');title('虚部');
% 此序列的模与相角
subplot(2,2,3);stem(n1,abs(x1));xlabel('n');ylabel('|x(n)|');title('模'); 
subplot(2,2,4);stem(n1,(180/pi)*angle(x1)); % 将弧度转为角度
xlabel('n');ylabel('\theta');title('相角');
figure;
% 幅度谱
subplot(3,1,1);stem(k1,abs(y1));xlabel('k');ylabel('|y|');title('幅度谱');
% 频谱实部
subplot(3,1,2);stem(k1,real(y1));xlabel('k');ylabel('Re\{y\}');title('频谱实部');
% 频谱虚部
subplot(3,1,3);stem(k1,imag(y1));xlabel('k');ylabel('Im\{y\}');title('频谱虚部');

% x(n)=sin(0.2*pi*n)+0.5sin(0.6*pi*n+0.5*pi)，序列长度为10
length2 = 10;
n2 = 0:length2-1;
x2 = sin(2*pi*0.1.*n2)+0.5*sin(2*pi*3*0.1.*n2+0.5*pi);
k2 = 0:length2-1;
y2 = dftmtx(10)*x2'; % DFT
figure; % 绘图
% 此序列的实部
subplot(2,2,1);stem(n2,real(x2));xlabel('n');ylabel('Re\{x(n)\}');title('实部');  
% 此序列的虚部
subplot(2,2,2);stem(n2,imag(x2));xlabel('n');ylabel('Im\{x(n)\}');title('虚部');
% 此序列的模与相角
subplot(2,2,3);stem(n2,abs(x2));xlabel('n');ylabel('|x(n)|');title('模'); 
subplot(2,2,4);stem(n2,(180/pi)*angle(x2)); % 将弧度转为角度
xlabel('n');ylabel('\theta');title('相角');
figure;
% 幅度谱
subplot(3,1,1);stem(k2,abs(y2));xlabel('k');ylabel('|y|');title('幅度谱');
% 频谱实部
subplot(3,1,2);stem(k2,real(y2));xlabel('k');ylabel('Re\{y\}');title('频谱实部');
% 频谱虚部
subplot(3,1,3);stem(k2,imag(y2));xlabel('k');ylabel('Im\{y\}');title('频谱虚部');

% x(n)=sin(0.2*pi*n)+0.5sin(0.6*pi*n+pi)，序列长度为10
length3 = 10;
n3 = 0:length3-1;
x3 = sin(2*pi*0.1.*n3)+0.5*sin(2*pi*3*0.1.*n3+pi);
k3 = 0:length3-1;
y3 = dftmtx(10)*x3'; % DFT
figure; % 绘图
% 此序列的实部
subplot(2,2,1);stem(n3,real(x3));xlabel('n');ylabel('Re\{x(n)\}');title('实部');  
% 此序列的虚部
subplot(2,2,2);stem(n3,imag(x3));xlabel('n');ylabel('Im\{x(n)\}');title('虚部');
% 此序列的模与相角
subplot(2,2,3);stem(n3,abs(x3));xlabel('n');ylabel('|x(n)|');title('模'); 
subplot(2,2,4);stem(n3,(180/pi)*angle(x3)); % 将弧度转为角度
xlabel('n');ylabel('\theta');title('相角');
figure;
% 幅度谱
subplot(3,1,1);stem(k3,abs(y3));xlabel('k');ylabel('|y|');title('幅度谱');
% 频谱实部
subplot(3,1,2);stem(k3,real(y3));xlabel('k');ylabel('Re\{y\}');title('频谱实部');
% 频谱虚部
subplot(3,1,3);stem(k3,imag(y3));xlabel('k');ylabel('Im\{y\}');title('频谱虚部');