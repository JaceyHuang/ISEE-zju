% prob1.m
clear;
clc;

omega0=2*pi*1000;
omegas=2*pi*8192; % 截止频率与采样频率

T=1/8192;
n=0:8192;
t=n*T;

x=sin(omega0*t);



