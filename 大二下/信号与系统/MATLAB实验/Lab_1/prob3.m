% prob3.m
clc;
clear;

% calculate the values of each signal
n=0:31;
x1=sin(n.*pi/4).*cos(n.*pi/4);
x2=cos(n.*pi/4).*cos(n.*pi/4);
x3=sin(n.*pi/4).*cos(n.*pi/8);

% the figure of x1[n]
figure;
stem(n,x1);
xlabel('n');
ylabel('x1[n]');
axis([0 31 -inf inf]); % Limit the range of abscissa

% the figure of x2[n]
figure;
stem(n,x2);
xlabel('n');
ylabel('x2[n]');
axis([0 31 -inf inf]); % Limit the range of abscissa

% the figure of x3[n]
figure;
stem(n,x3);
xlabel('n');
ylabel('x3[n]');
axis([0 31 -inf inf]); % Limit the range of abscissa