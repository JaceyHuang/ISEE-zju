% prob2b.m
clear;
clc;
 
% time vector
t=0:0.05:4;
 
% the coefficients of the differential equation
a=[1,3];
b=1;
 
% get the step response by using step command
figure;
step(b,a,t);
 
% get the impulse response by using impulse command
figure;
impulse(b,a,t);