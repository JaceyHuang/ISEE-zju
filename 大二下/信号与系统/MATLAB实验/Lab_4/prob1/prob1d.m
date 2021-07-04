% prob1d.m

clear;
clc;

nx=0:99;
x=cos(nx.^2).*sin(2*pi/5.*nx); % x[n]

nh=0:99;
h=0.9.^nh.*(nh>=0 & nh<=9); % h[n]

y=conv(h,x);
ny=0:198; % range for y[n]
stem(ny,y); 
xlabel('n');
ylabel('y[n]');
title('y[n]');
