% prob3k.m

clear;
clc;

t=-5:0.01:5;

% the new coefficient vectors
a_new=[-1 1 -24 -26];
b_new=[1 -7 21];

% the analytic expression
ha=-(exp(-t).*sin(5*t)+exp(t)).*(t<=0);

% the causal response
h_c1=impulse(b_new,a_new,t);
% append the result
h_c=[zeros(length(t)-length(h_c1),1);h_c1];

% time-reverse the simulated response and plot 
h_ac=flipud(h_c);
plot(t,ha);
hold on;
plot(t,h_ac);
title('the impulse response');
xlabel('t');
ylabel('Amplitude');
legend('analytic expression','impulse response');