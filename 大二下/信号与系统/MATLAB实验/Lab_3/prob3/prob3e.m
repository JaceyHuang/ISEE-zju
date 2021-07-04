% prob3e.m
clear;
clc;

t=-5:0.01:5;
ha=-exp(-2*t).*(t<=0);

% the new coefficients
a_new=[-1 2];
b_new=1;
h_c=impulse(b_new,a_new,t);

% append the result
h_c1=[zeros(length(t)-length(h_c),1);h_c];

% flip the impulse response and plot
h_ac=flipud(h_c1);
plot(t,ha);
hold on;
plot(t,h_ac);
title('the impulse response');
xlabel('t');
ylabel('Amplitude');
legend('analytic expression','impulse response');