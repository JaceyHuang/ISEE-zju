% prob5a.m
clc;
clear;

% prove nonlinearity
n=0:10;
x1=[1,zeros(1,10)];
x2=2*x1;
x3=x1+x2;
y1=sin(x1.*pi/2);
y2=sin(x2.*pi/2);
y3=sin(x3.*pi/2);

% plot y1+y2
figure;
subplot(2,1,1);
stem(n,y1+y2);
xlabel('n');
ylabel('y1[n]+y2[n]');

% plot y3
subplot(2,1,2);
stem(n,y3);
xlabel('n');
ylabel('y3[n]');