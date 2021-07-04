% prob1a.m

clear;
clc;

x=[1 0 1]; % input and impulse response
h=[2 0 -2];
y=conv(h,x); % convolution
ny=-1:3;
stem(ny,y);
title('y[n]');
xlabel('n');
ylabel('y[n]');