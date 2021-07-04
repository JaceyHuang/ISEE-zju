% prob2a.m
clear;
clc;

% time vector
t=-1:0.05:4;

% the unit step response
s=(-1/3*exp(-3*t)+1/3).*(t>=0);

% the unit impulse response
h=exp(-3*t).*(t>=0);

% figure of s(t)
figure;
plot(t,s);
title('Unit Step Response');
xlabel('t');
ylabel('s(t)');

% figure of h(t)
figure;
plot(t,h);
title('Unit Impulse Response');
xlabel('t');
ylabel('h(t)');
