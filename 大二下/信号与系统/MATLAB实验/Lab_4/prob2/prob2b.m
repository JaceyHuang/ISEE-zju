% prob2b.m

clear;
clc;

wc=0.4;
n1=10;n2=4;n3=12;
[b1,a1]=butter(n1,wc);
a2=1;b2=remez(n2,[0 wc-0.04 wc+0.04 1],[1 1 0 0]);
a3=1;b3=remez(n3,[0 wc-0.04 wc+0.04 1],[1 1 0 0]);

figure; % filter_1
freqz(b1,a1);
title('filter 1');

figure; % filter_2
freqz(b2,a2);
title('filter 2');

figure;% filter_3
freqz(b3,a3);
title('filter 3');