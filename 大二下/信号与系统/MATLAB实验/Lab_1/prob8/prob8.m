% prob8.m
clc;
clear;

x=str2sym('exp(i*2*pi*t/16)+exp(i*2*pi*t/8)');
xr=sreal(x); % get the real component of x
xi=simag(x); % get the imaginary component of x

% plot of the real part
ezplot(xr,0,32);

% plot of the imaginary part
% when need to draw the imaginary part, note off the following sentence
% ezplot(xi,0,32);