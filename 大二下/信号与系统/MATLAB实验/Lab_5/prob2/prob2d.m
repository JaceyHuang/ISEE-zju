% prob2d.m
clear;
clc;

load origbl;
fs=8192;
N=length(x);
t=(1:1:N)/fs;
fc=1500;
T=40/fs/2;
wc=2*pi*fc;
y=x'.*cos(2*pi*fc*t);
w=y.*cos(2*pi*fc*t);

h=wc*sin(2*pi*fc.*t)./(pi*wc.*t);
h=[h(20:-1:1) h(1) h(1:20)].*hamming(41)';
H=fftshift(fft(h,8192));

figure;
plot(t(1:41),h(1:41));
figure;
plot(-fs/2:fs/2-1,abs(H));

% e
z=filter(h,1,w);
Z=fft(z,N)/N;
figure;
% plot(-fs/2:fs/2-1,abs(Z));

% g
phi=pi/4;
A=10;
y=(x+A)'.*cos(2*pi*fc*t+phi);
alpha=0.1;
phihat=zeros(1,N);
phihat(1)=0;
chat=zeros(1,N);
for k=1:N-1
    chat(k)=A*cos(2*pi*fc*t(k)+phihat(k));
    phihat(k+1)=phihat(k)+alpha*(y(k)-chat(k));
end
figure;
plot(t,phihat);

w=y.*cos(2*pi*fc*t+phihat(end))*2-A;