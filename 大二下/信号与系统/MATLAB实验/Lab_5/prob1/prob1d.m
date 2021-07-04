% prob1d.m
clear;
clc;

omega01=2*pi*1500;
omega02=2*pi*2000;
omegas=2*pi*8192; % 截止频率与采样频率

T=1/8192;
n=0:8192;
t=n*T;

x1=sin(omega01*t);
x2=sin(omega02*t);

[X1,w]=ctfts(x1,T);
figure;
plot(w,abs(X1));
xlabel('w');
ylabel('|X|');
title('M-F Response');
figure;
plot(w,angle(X1));
xlabel('w');
ylabel('Phase');
title('P-F Response');

[X2,w]=ctfts(x2,T);
figure;
plot(w,abs(X2));
xlabel('w');
ylabel('|X|');
title('M-F Response');
figure;
plot(w,angle(X2));
xlabel('w');
ylabel('Phase');
title('P-F Response');