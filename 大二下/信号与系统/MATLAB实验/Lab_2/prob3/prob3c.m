% prob3c.m
clear;
clc;

N=1000;
alpha=0.5;

% the coefficients of the difference equations
a=zeros(1,N+1);
a(1)=1;
a(N+1)=alpha;
b=1;

% the input signal
d=[1 zeros(1,4000)];

% simulate the impulse response by filter
her=filter(b,a,d);
stem(0:4000,her);
title('Impulse Response');
xlabel('n');
ylabel('h[n]');