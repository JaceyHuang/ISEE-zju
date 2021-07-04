% prob2c.m

clear;
clc;

wc=0.4;
n1=10;n2=4;n3=12;
[b1,a1]=butter(n1,wc);
a2=1;b2=remez(n2,[0 wc-0.04 wc+0.04 1],[1 1 0 0]);
a3=1;b3=remez(n3,[0 wc-0.04 wc+0.04 1],[1 1 0 0]);

n=1:20; % the input signal
x=ones(1,20);
h1=filter(b1,a1,x); % the step responses
h2=filter(b2,a2,x);
h3=filter(b3,a3,x);

figure;
stem(n,h1);
xlabel('n');
ylabel('Amplitude');
title('filter 1');

figure;
stem(n,h2);
xlabel('n');
ylabel('Amplitude');
title('filter 2');

figure;
stem(n,h3);
xlabel('n');
ylabel('Amplitude');
title('filter 3');
