% prob7.m

clc;
clear;

x=str2sym('sin(2*pi*t/T)'); % create a symbolic expression
x5=subs(x,'T',5); % substitute 5 for 'T'
ezplot(x5,0,10); % plot the expression for two periods