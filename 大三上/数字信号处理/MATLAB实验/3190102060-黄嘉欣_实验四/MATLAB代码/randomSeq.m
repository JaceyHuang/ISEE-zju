% randomSeq.m
clc; clear;

N = 200; % 长度
n = 0:N-1;
x = rand(1,N)-0.5; % 产生随机信号序列
X = dftmtx(N)*x'; % 离散傅里叶变换

% 将X(k)写入文件
f1 = fopen('../MATLAB计算结果/randomSeq.txt','w');
for i = 1:N
    fprintf(f1,'X(%d) = %.5f\n',i-1,X(i));
end

% 绘图
subplot(2,1,1); stem(n,x,'filled');
title('信号序列'); xlabel('n'); ylabel('magnitude');
subplot(2,1,2); stem(n,abs(X),'filled');
title('幅度谱'); xlabel('k'); ylabel('magnitude');