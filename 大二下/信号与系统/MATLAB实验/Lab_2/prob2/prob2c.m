% prob2c.m
 
clear;
clc;
 
% the time vector
t=-1:0.05:4;
 
% coefficients of the equation
a=[1 3];
b=1;
 
dt1=0.1;
dt2=0.2;
dt3=0.4;
 
% the input signals
d1=zeros(1,length(t));
% in the interval [0,dt), the inputs are 1/dt
d1(1,1/0.05+1:1/0.05+dt1/0.05)=1/dt1;
d2=zeros(1,length(t));
d2(1,1/0.05+1:1/0.05+dt2/0.05)=1/dt2;
d3=zeros(1,length(t));
d3(1,1/0.05+1:1/0.05+dt3/0.05)=1/dt3;
 
% simulate the corresponding outputs by using lsim command
h1=lsim(b,a,d1,t);
h2=lsim(b,a,d2,t);
h3=lsim(b,a,d3,t);
 
% the output we computed in (a)
h=exp(-3*t).*(t>=0);
 
% figure of h1(t)
figure;
plot(t,h1);
title('h1');
xlabel('t');
ylabel('Amplitude');
hold on;
plot(t,h); % plot h(t)
legend('h1(t)','h(t)');
 
% figure of h2(t)
figure;
plot(t,h2);
title('h2');
xlabel('t');
ylabel('Amplitude');
hold on;
plot(t,h);
legend('h2(t)','h(t)');
 
% figure of h3(t)
figure;
plot(t,h3);
title('h3');
xlabel('t');
ylabel('Amplitude');
hold on;
plot(t,h);
legend('h3(t)','h(t)');