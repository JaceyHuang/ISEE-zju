% prob1c.m

clear;
clc;

% the coefficients of the equation
b=[1 2 5];
a=[1 -3];
% the zeros and poles
zs=roots(b)
ps=roots(a)
figure;
plot(real(zs),imag(zs),'o');
hold on;
plot(real(ps),imag(ps),'x');
axis([-5 5 -3 3]);
grid on;
title('pole-zero diagram');