% prob1f.m
clear;
clc;

omega0=2*pi*3500; % 4000、4500、5000、5500
omegas=2*pi*8192; % 截止频率与采样频率

T=1/8192;
n=0:8192;
t=n*T;

x=sin(omega0*t);

[X,w]=ctfts(x,T);
figure;
plot(w,abs(X));
xlabel('w');
ylabel('|X|');
title('M-F Response');
figure;
plot(w,angle(X));
xlabel('w');
ylabel('Phase');
title('P-F Response');

sound(x,1/T);