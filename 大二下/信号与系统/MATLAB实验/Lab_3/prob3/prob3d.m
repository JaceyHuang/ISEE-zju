% prob3d.m

clear;
clc;

t=-5:0.01:5;
a=[1 2];
b=1;

% the analytic expression
ha=exp(-2.*t).*(t>=0);

% the impulse response
h1=impulse(b,a,t);
% append the result and plot
h=[zeros(length(t)-length(h1),1);h1];
figure;
plot(t,ha);
hold on;
plot(t,h);
title('the impulse response');
xlabel('t');
ylabel('Amplitude');
legend('analytic expression','impulse response');