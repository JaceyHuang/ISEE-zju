% prob2b.m
clear;
clc;

load origbl;
fs=8192;
N=length(x);
t=(1:1:N)/fs;
sound(x,8192);

figure;
fc=1500;
y=x'.*cos(2*pi*fc*t);
Y=fft(y,N)/N;
f=(1:N/2)*fs/N;
plot(f,abs(Y(1:N/2)));

% prob2c
figure;
w=y.*cos(2*pi*fc*t);
W=fft(w,N)/N;
plot(f,abs(W(1:N/2)));