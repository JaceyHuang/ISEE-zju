% prob3i.m

clear;
clc;

% the coefficient vectors
b=[1 7 21];
a=[1 1 24 -26];

% use residue to determine the partial fraction expansion
[r,p,k]=residue(b,a)