% prob1a_system1.m
clear;
clc;
 
% the input signals
x1=[1 0 0 0 0 0];
x2=[0 1 0 0 0 0];
x3=[1 2 0 0 0 0];
 
% the coefficients of the difference equation
a=[1 0 0];
b=[1 -1 -1];
 
% compute the output signals by using filter command
w1=filter(b,a,x1);
w2=filter(b,a,x2);
w3=filter(b,a,x3);
w4=w1+2*w2;
 
% figure of w1[n]
subplot(2,2,1);
stem(0:5,w1);
title('w1');
xlabel('n');
ylabel('w1[n]');
axis([0 5 -inf inf]);
 
% figure of w2[n]
subplot(2,2,2);
stem(0:5,w2);
title('w2');
xlabel('n');
ylabel('w2[n]');
axis([0 5 -inf inf]);
 
% figure of w3[n]
subplot(2,2,3);
stem(0:5,w3);
title('w3');
xlabel('n');
ylabel('w3[n]');
axis([0 5 -inf inf]);
 
% figure of w4[n]
subplot(2,2,4);
stem(0:5,w4);
title('w4');
xlabel('n');
ylabel('w4[n]');
axis([0 5 -inf inf]); % Limit the range of abscissa