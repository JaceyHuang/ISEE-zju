% prob2d.m

clear;
clc;

load plus;

wc=0.4;
n1=10;n2=4;n3=12;
[b1,a1]=butter(n1,wc);
a2=1;b2=remez(n2,[0 wc-0.04 wc+0.04 1],[1 1 0 0]);
a3=1;b3=remez(n3,[0 wc-0.04 wc+0.04 1],[1 1 0 0]);

x16=x(:,16);
y16_2=filter(b2,a2,[x16;zeros(n2/2,1)]); % filter 2's response
y16_3=filter(b3,a3,[x16;zeros(n3/2,1)]); % filter 3's response

figure;
stem(x16);
hold on;
stem(y16_2(n2/2+1:end));
hold on;
stem(y16_3(n3/2+1:end));
xlabel('n');
ylabel('Amplitude');
legend('x16','y16 filter 2','y16 filter 3');