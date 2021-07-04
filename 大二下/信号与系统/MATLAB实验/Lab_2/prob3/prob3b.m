% prob3b.m
clear;
clc;

N=1000;
alpha=0.5;

% the coefficients of the difference equations
a=1;
b=zeros(1,N+1);
b(1)=1;
b(N+1)=alpha;

% the input signal in (a)
delta=zeros(1,N+1);
delta(1)=1;

% the impulse response in (a)
he=filter(b,a,delta);

% simulate and plot the output of the system by using filter
z=filter(a,b,he);
stem(0:1000,z);
title('Corresponding Output to h[n]');
xlabel('n');
ylabel('z[n]');