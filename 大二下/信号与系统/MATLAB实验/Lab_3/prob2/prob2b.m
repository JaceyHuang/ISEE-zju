% prob2b.m
clear;
clc;

% the coefficient vectors
a=[1 1 0.5];
b=[1 0 0];

% draw the diagram
dpzplot(b,a);
title('the pole-zero diagram');