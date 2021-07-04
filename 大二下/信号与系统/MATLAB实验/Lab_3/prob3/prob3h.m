% prob3h.m

clear;
clc;

a=[1 1 24 -26];
b=[1 7 21];

zs=roots(b)
ps=roots(a)

% plot the pole-zero diagram
figure;
plot(real(zs),imag(zs),'o');
hold on;
plot(real(ps),imag(ps),'x');
axis([-6 6 -8 8]);
grid on;
title('pole-zero diagram');

% figure;
% pzplot(b,a,1);