% prob2a.m
clear;
clc;

load origbl;
fs=8192;
N=length(x);
t=(1:1:N)/fs;
sound(x,8192);

X=fft(x,N)/N;
f=(1:N/2)*fs/N;
plot(f,abs(X(1:N/2)));