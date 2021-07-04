% prob2a.m
clear;
clc;

% the coefficients of the equation
b=[1 -1];
a=[1 3 2];

% plot the diagram
dpzplot(b,a);
title('the pole-zero diagram');