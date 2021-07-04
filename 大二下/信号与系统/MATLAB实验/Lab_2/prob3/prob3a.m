% prob3a.m
clear;
clc;

N=1000;
alpha=0.5;

% the coefficients of the difference equation (2.21)
a=1;
b=zeros(1,N+1);
b(1)=1;
b(N+1)=alpha;

% the input signal
delta=zeros(1,N+1);
delta(1)=1;

% simulate and plot the impulse response using the filter command
he=filter(b,a,delta);
stem(0:1000,he);
title('Impulse Response');
xlabel('n');
ylabel('h[n]');