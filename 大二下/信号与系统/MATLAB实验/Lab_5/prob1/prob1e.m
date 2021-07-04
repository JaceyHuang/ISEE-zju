% prob1e.m
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

subplot(2,1,1);
stem(0:49,x1(1:50));
xlabel('n');
ylabel('x[n]');
title('Discrete-time signal x[n]');
subplot(2,1,2);
plot(0:49,x1(1:50));
xlabel('t');
ylabel('x(t)');
title('Continuous-time signal x(t)');

subplot(2,1,1);
stem(0:49,x2(1:50));
xlabel('n');
ylabel('x[n]');
title('Discrete-time signal x[n]');
subplot(2,1,2);
plot(0:49,x2(1:50));
xlabel('t');
ylabel('x(t)');
title('Continuous-time signal x(t)');

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

sound(x1,1/T);
sound(x2,1/T);