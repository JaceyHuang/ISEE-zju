% prob3e.m

clear;
clc;

x1=ones(1,8);
x2=[ones(1,8),zeros(1,8)];
x3=[ones(1,8),zeros(1,24)];

% use fft to compute coefficients
a1=1/8*fft(x1); 
a2=1/16*fft(x2);
a3=1/32*fft(x3);

a1_s=abs(a1); % the magnitude
a2_s=abs(a2);
a3_s=abs(a3);

figure;
stem(a1_s);
xlabel('n');
ylabel('Magnitude');
title('a1');

figure;
stem(a2_s);
xlabel('n');
ylabel('Magnitude');
title('a2');

figure;
stem(a3_s);
xlabel('n');
ylabel('Magnitude');
title('a3');
