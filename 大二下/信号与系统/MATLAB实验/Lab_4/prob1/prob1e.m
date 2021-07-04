% prob1e.m

clear;
clc;

n=0:99;
h=0.9.^n.*(n>=0&n<10); % h[n]

nx0=0:49;
x0=cos(nx0.^2).*sin(2*pi/5.*nx0); % x0[n]
nx1=nx0+50;
x1=cos(nx1.^2).*sin(2*pi/5.*nx1); % x1[n]

y0=conv(h,x0); % y0[n]
y1=conv(h,x1); % y1[n]
y=[y0 zeros(1,50)]+[zeros(1,50) y1]; % y0[n]+y1[n-50]
stem(n,y(1:100));
xlabel('n');
ylabel('y[n]');
title('y[n]');