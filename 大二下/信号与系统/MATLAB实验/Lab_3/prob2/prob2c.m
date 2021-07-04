% prob2c.m
clear;
clc;

% the coefficient vectors
a=[1 -1.25 0.75 -0.125];
b=[1 0.5 0 0];

% draw the diagram
dpzplot(b,a);
title('the pole-zero diagram');