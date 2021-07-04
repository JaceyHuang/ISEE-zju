% prob2a.m

clear;
clc;

wc=0.4; % cutoff frequency
n1=10;n2=4;n3=12; % orders
[b1,a1]=butter(n1,wc); % coefficients
a2=1;b2=remez(n2,[0 wc-0.04 wc+0.04 1],[1 1 0 0]);
a3=1;b3=remez(n3,[0 wc-0.04 wc+0.04 1],[1 1 0 0]);
