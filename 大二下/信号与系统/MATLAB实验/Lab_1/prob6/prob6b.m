% prob6b.m

clc;
clear;

n=0:30;
a=1;
yn=0;
x1=[1,zeros(1,30)]; % unit impulse signal
x2=[ones(1,31)]; % unit step signal
y1=diffeqn(a,x1,yn);
y2=diffeqn(a,x2,yn);

% the unit impulse signal
figure;
stem(-1:30,y1);
title('response to unit impulse signal');
xlabel('n');
ylabel('y1[n]');
axis([-1 30 -inf inf]);

%the unit step signal
figure;
stem(-1:30,y2);
title('response to unit step signal');
xlabel('n');
ylabel('y2[n]');
axis([-1 30 -inf inf]);