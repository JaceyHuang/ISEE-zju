% prob1a_system3.m
clear;
clc;
 
n=0:1:5;
 
% the input signals
x1=[1 0 0 0 0 0];
x2=[0 1 0 0 0 0];
x3=[1 2 0 0 0 0];
 
% the output signals
z1=n.*x1;
z2=n.*x2;
z3=n.*x3;
z4=z1+2*z2;
 
% figure of z1[n]
subplot(2,2,1);
stem(n,z1);
title('z1');
xlabel('n');
ylabel('z1[n]');
axis([0 5 -1 1]);
 
% figure of z2[n]
subplot(2,2,2);
stem(n,z2);
title('z2');
xlabel('n');
ylabel('z2[n]');
axis([0 5 -inf inf]);
 
% figure of z3[n]
subplot(2,2,3);
stem(n,z3);
title('z3');
xlabel('n');
ylabel('z3[n]');
axis([0 5 -inf inf]);
 
% figure of z4[n]
subplot(2,2,4);
stem(n,z4);
title('z4');
xlabel('n');
ylabel('z4[n]');
axis([0 5 -inf inf]); % Limit the range of abscissa