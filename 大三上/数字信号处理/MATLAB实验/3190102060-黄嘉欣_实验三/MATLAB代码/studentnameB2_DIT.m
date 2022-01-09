% studentnameB2_DIT.m
clc;
clear;

% 输入序列，前10点为学号，后补6个0
x = [3 1 9 0 1 0 2 0 6 0 0 0 0 0 0 0]; 
N = 16; % 点数
n = 0:N-1;
figure; stem(n,x,'filled'); % 输入序列图形
xlabel('n'); ylabel('x(n)'); title('输入序列');

XDFT = dftmtx(N)*x'; % 输入序列的DFT
X1 = zeros(2,8); % 初始化第一级蝶形运算结果
X2 = zeros(4,4); % 初始化第二级蝶形运算结果
X3 = zeros(8,2); % 初始化第三级蝶形运算结果

X = zeros(16,1); % 初始化输出的频谱序列
W = exp(-1j*2*pi/N); % W_16^1
W2 = dftmtx(2); % 2点DFT系数矩阵
x0 = [x(1);x(9)]; x1 = [x(5);x(13)]; % 分组
x2 = [x(3);x(11)]; x3 = [x(7);x(15)]; 
x4 = [x(2);x(10)]; x5 = [x(6);x(14)];
x6 = [x(4);x(12)]; x7 = [x(8);x(16)];

% 第一级蝶形复合
X1(:,1) = W2*x0; X1(:,2) = W2*x1; X1(:,3) = W2*x2; X1(:,4) = W2*x3;
X1(:,5) = W2*x4; X1(:,6) = W2*x5; X1(:,7) = W2*x6; X1(:,8) = W2*x7;
% 第二级蝶形复合
for k = 0:1 
    for m = 0:3 % 每次循环求出两点
        t1 = W2*[X1(k+1,2*m+1);W^(4*k)*X1(k+1,2*m+2)];
        X2(k+1,m+1) = t1(1); X2(k+3,m+1) = t1(2); 
    end
end
% 第三级蝶形复合
for k = 0:3 
    for m = 0:1 % 每次循环求出两点
        t2 = W2*[X2(k+1,2*m+1);W^(2*k)*X2(k+1,2*m+2)];
        X3(k+1,m+1) = t2(1); X3(k+5,m+1) = t2(2);
    end
end
% 第四级蝶形复合
for k = 0:7
    t3 = W2*[X3(k+1,1);W^k*X3(k+1,2)]; 
    X(k+1) = t3(1); X(k+9) = t3(2);
end

figure;
subplot(2,2,1); stem(n,real(XDFT),'filled');
xlabel('k'); ylabel('Re\{X\}'); title('DFT所得频谱实部');
subplot(2,2,2); stem(n,imag(XDFT),'filled');
xlabel('k'); ylabel('Im\{X\}'); title('DFT所得频谱虚部');
subplot(2,2,3); stem(n,real(X),'filled');
xlabel('k'); ylabel('Re\{X\}'); title('基2DIT-FFT频谱实部');
subplot(2,2,4); stem(n,imag(X),'filled');
xlabel('k'); ylabel('Im\{X\}'); title('基2DIT-FFT频谱虚部');

% 将数据写入文件
f = fopen('studentnameB2_DIT.txt','w');
for i = 1:16
    if imag(X(i))<0
        fprintf(f,'X(%d) = %f-j%f\n',i-1,real(X(i)),-imag(X(i)));
    else
        fprintf(f,'X(%d) = %f+j%f\n',i-1,real(X(i)),imag(X(i))); 
    end
end