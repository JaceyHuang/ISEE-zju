% prob1a_system2.m
clear;
clc;
 
% the input signals
x1=[1 0 0 0 0 0];
x2=[0 1 0 0 0 0];
x3=[1 2 0 0 0 0];
 
% the output signals
y1=cos(x1);
y2=cos(x2);
y3=cos(x3);
y4=y1+2*y2;
 
% figure of y1[n]
subplot(2,2,1);
stem(0:5,y1);
title('y1');
xlabel('n');
ylabel('y1[n]');
axis([0 5 0 1]);
 
% figure of y2[n]
subplot(2,2,2);
stem(0:5,y2);
title('y2');
xlabel('n');
ylabel('y2[n]');
axis([0 5 0 1]);
 
% figure of y3[n]
subplot(2,2,3);
stem(0:5,y3);
title('y3');
xlabel('n');
ylabel('y3[n]');
axis([0 5 -0.5 1]);
 
% figure of y4[n]
subplot(2,2,4);
stem(0:5,y4);
title('y4');
xlabel('n');
ylabel('y4[n]');
axis([0 5 0 3]); % Limit the range of abscissa