% prob1.m
clc;
clear;

k=[1,2,4,6];
n=0:9;
wk=2*pi*k/5;
x=sin(wk'*n);

% k=1
subplot(4,1,1);
stem(n,x(1,:));
title('k=1');
xlabel('n');
ylabel('x1[n]');

% k=2
subplot(4,1,2);
stem(n,x(2,:));
title('k=2');
xlabel('n');
ylabel('x2[n]');

% k=4
subplot(4,1,3);
stem(n,x(3,:));
title('k=4');
xlabel('n');
ylabel('x4[n]');

% k=6
subplot(4,1,4);
stem(n,x(4,:));
title('k=6');
xlabel('n');
ylabel('x6[n]');