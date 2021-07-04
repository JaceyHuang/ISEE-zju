% prob3d.m
clear;
clc;

load('lineup.mat')

N=1000;
alpha=0.5;

% the coefficients of the difference equation
a=zeros(1,N+1);
a(1)=1;
a(N+1)=alpha;
b=1;

% simulate the output by filter command
z=filter(b,a,y);
plot(z);
title('Echoless Sound');
xlabel('n');
ylabel('z[n]');

% hear the output sound
sound(z,8192);

% save the wave file
fs=8000;
audiowrite('lineup.wav',z/6,fs); % prevent z from being cut