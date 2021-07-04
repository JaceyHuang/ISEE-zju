% prob1d.m

clear;
clc;

% the coefficients of the equation
b=[1 2 5];
a=[1 -3];

% use pzplot to determine the poles and zeros while making the plot
% [ps,zs]=pzplot(b,a,1);
[ps,zs]=pzplot(b,a,5);
% [ps,zs]=pzplot(b,a,3);
title('the pole-zero diagram');