% prob2g.m

clear;
clc;

load plus;

wc=0.4;
n1=10;n2=4;n3=12;
[b1,a1]=butter(n1,wc);
a2=1;b2=remez(n2,[0 wc-0.04 wc+0.04 1],[1 1 0 0]);
a3=1;b3=remez(n3,[0 wc-0.04 wc+0.04 1],[1 1 0 0]);

y1=filt2d(b1,a1,n1/2,x); % use function filt2d to filter
y2=filt2d(b2,a2,n2/2,x); % filter 2
y3=filt2d(b3,a3,n3/2,x); % filter 3

figure;
image(y1*64);
title('filter 1');
figure;
image(y2*64);
title('filter 2');
figure;
image(y3*64);
title('filter 3');