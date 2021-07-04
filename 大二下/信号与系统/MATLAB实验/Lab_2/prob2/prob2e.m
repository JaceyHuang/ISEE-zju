% prob2e.m
 
clear;
clc;
 
% the time vector
t=-1:0.05:4;
 
% coefficients of the equation
a=[1 3];
b=1;
 
a1=4;
a2=8;
a3=16;
 
% values of da(t)
da1=a1*exp(-a1*t).*(t>=0);
da2=a2*exp(-a2*t).*(t>=0);
da3=a3*exp(-a3*t).*(t>=0);
 
% simulate the output signals by using lsim command
h1=lsim(b,a,da1,t);
h2=lsim(b,a,da2,t);
h3=lsim(b,a,da3,t);
 
% the output we computed in (a)
h=exp(-3*t).*(t>=0);
 
% figure of h1
figure;
plot(t,h1);
title('h1');
xlabel('t');
ylabel('Amplitude');
hold on;
plot(t,h); % plot h(t)
legend('h1(t)','h(t)');
 
% figure of h2
figure;
plot(t,h2);
title('h2');
xlabel('t');
ylabel('Amplitude');
hold on;
plot(t,h);
legend('h2(t)','h(t)');
 
% figure of h3
figure;
plot(t,h3);
title('h3');
xlabel('t');
ylabel('Amplitude');
hold on;
plot(t,h);
legend('h3(t)','h(t)');