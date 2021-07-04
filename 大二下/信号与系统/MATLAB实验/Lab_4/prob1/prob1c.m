% prob1c.m

clear;
clc;

nx=0:24;
x=(0.5.^(nx-2)).*(nx>=2); % x[n]

nh=0:14;
h=ones(1,15); % h[n]

y=conv(h,x);
ny=0:38;
stem(ny,y,'b'); % truncated output

hold on;
stem(ny,2-2.^(-ny),'g'); % analytical output

hold on;
stem(ny,y-2+2.^(-ny),'r');  % difference between the two outputs
xlabel('n');
ylabel('Amplitude');
legend('y*[n]','y[n]','y*[n]-y[n]');