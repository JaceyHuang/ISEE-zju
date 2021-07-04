% prob3p.m

clear;
clc;

t=[-10:0.01:10];

% coefficients of the causal system
a1=[1 2 26];
b1=5;

% coefficients of the anticausal system
a2_new=[-1 -1];
b2_new=1;

% the input signals
x=(t>=-3).*(t<=2);
% time-inverse
x_reverse=fliplr(x);

% simulate y1
y1_old=lsim(b1,a1,x,t);
y1=[zeros(length(t)-length(y1_old),1);y1_old];

% simulate y2
y2_c=lsim(b2_new,a2_new,x_reverse,t);
y2=[zeros(length(t)-length(y2_c),1);y2_c];
% time-inverse
y2_ac=flipud(y2);

% plot the figure
figure;
subplot(3,1,1);
plot(t,y1);
title('y1');
xlabel('t');
ylabel('Amplitude');
subplot(3,1,2);
plot(t,y2_ac);
title('y2');
xlabel('t');
ylabel('Amplitude');
subplot(3,1,3);
plot(t,y1+y2_ac);
title('y');
xlabel('t');
ylabel('Amplitude');