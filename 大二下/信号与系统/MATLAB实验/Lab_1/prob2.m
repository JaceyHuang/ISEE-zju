% prob2.m
clc;
clear;

% x1[n] is periodic and its period is 12
figure;
n1=0:23;
x1=cos(n1.*pi/3)+2*cos(n1.*pi/2);
stem(n1,x1);
xlabel('n');
ylabel('x1[n]');
axis([0 23 -inf inf]); % Limit the range of abscissa

% x2[n] is not periodic, so we plot for 0<=n<=24
figure;
n2=0:24;
x2=2*cos(n2./3)+cos(n2./2);
stem(n2,x2);
xlabel('n');
ylabel('x2[n]');
axis([0 24 -inf inf]); % Limit the range of abscissa

% x3[n] is periodic and its period is 24
figure;
n3=0:47;
x3=cos(n3.*pi/3)+3*sin(n3.*pi*5/12);
stem(n3,x3);
xlabel('n');
ylabel('x3[n]');
axis([0 47 -inf inf]); % Limit the range of abscissa
