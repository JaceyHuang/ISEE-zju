% prob3j.m

clear;
clc;

t=-5:0.01:5;

% the coefficient vectors
a=[1 1 24 -26];
b=[1 7 21];

ha=(exp(-t).*sin(5*t)+exp(t)).*(t>=0);
h1=impulse(b,a,t);
% append the result and plot
h=[zeros(length(t)-length(h1),1);h1];
plot(t,ha);
hold on;
plot(t,h);
title('the impulse response');
xlabel('t');
ylabel('Amplitude');
legend('analytic expression','impulse response');