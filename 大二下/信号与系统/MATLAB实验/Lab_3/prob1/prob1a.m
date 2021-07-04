% prob1a.m

clear;
clc;

% zeros and poles of (i)
b1=[1 5];
a1=[1 2 3];
zs1=roots(b1)
ps1=roots(a1)
% plot the pole-zero diagram
figure;
plot(real(zs1),imag(zs1),'o');
hold on;
plot(real(ps1),imag(ps1),'x');
axis([-5 5 -5 5]);
grid on;
title('pole-zero diagram of (i)');

% zeros and poles of (ii)
b2=[2 5 12];
a2=[1 2 10];
zs2=roots(b2)
ps2=roots(a2)
% plot the pole-zero diagram
figure;
plot(real(zs2),imag(zs2),'o');
hold on;
plot(real(ps2),imag(ps2),'x');
axis([-5 5 -5 5]);
grid on;
title('pole-zero diagram of (ii)');

% zeros and poles of (iii)
b3=[2 5 12];
a3=conv(a2,[1 2]);
zs3=roots(b3)
ps3=roots(a3)
% plot the pole-zero diagram
figure;
plot(real(zs3),imag(zs3),'o');
hold on;
plot(real(ps3),imag(ps3),'x');
axis([-5 5 -5 5]);
grid on;
title('pole-zero diagram of (iii)');

