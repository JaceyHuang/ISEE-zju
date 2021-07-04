% prob3g.m

clear;
clc;

% the new coefficient vectors
a_new=[-1 2];
b_new=1;

t=-5:0.01:5;

% the analytic expression
y=2/9*exp(5*t/2).*(1-exp(-9/2*t)).*(t<=0);

x=exp(5*t/2).*(t<=0);

% the causal response
x_reverse=exp(-5*t/2).*(t>=0);
w1=lsim(b_new,a_new,x_reverse,t);

% time-reverse the simulated response and plot
w=flipud(w1);
plot(t,y);
hold on;
plot(t,w);
title('the output siganl');
xlabel('t');
ylabel('Amplitude');
legend('analytic expression',"system's output")
