% prob2.m
clear;
clc;

omega0=2*pi*1000;
omegas=2*pi*8192; % 截止频率与采样频率

T=1/8192;
n=0:8192;
t=n*T;

x=sin(omega0*t);

subplot(2,1,1);
stem(0:49,x(1:50));
xlabel('n');
ylabel('x[n]');
title('Discrete-time signal x[n]');
subplot(2,1,2);
plot(0:49,x(1:50));
xlabel('t');
ylabel('x(t)');
title('Continuous-time signal x(t)');