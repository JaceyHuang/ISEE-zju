% prob3d.m

clear;
clc;

x1=ones(1,8); % each periodic signal
x2=[ones(1,8),zeros(1,8)];
x3=[ones(1,8),zeros(1,24)];
n=0:63;

x1_0=[x1 x1 x1 x1 x1 x1 x1 x1]; 
x2_0=[x2 x2 x2 x2];
x3_0=[x3 x3]; % repeat the vectors

figure;
stem(n,x1_0);
xlabel('n');
ylabel('x1[n]');
title('x1[n]');
axis([0 63 -inf inf]);

figure;
stem(n,x2_0);
xlabel('n');
ylabel('x2[n]');
title('x2[n]');
axis([0 63 -inf inf]);

figure;
stem(n,x3_0);
xlabel('n');
ylabel('x3[n]');
title('x3[n]');
axis([0 63 -inf inf]);
