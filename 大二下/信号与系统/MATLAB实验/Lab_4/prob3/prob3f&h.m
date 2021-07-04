% prob3f&h.m

clear;
clc;

x3=[ones(1,8),zeros(1,24)];
a3=1/32*fft(x3); % the FTFS coefficients
nx=0:31;

x3_2=zeros(1,32); % preset the memory
x3_8=zeros(1,32);
x3_12=zeros(1,32);
x3_all=zeros(1,32);

for n=1:32 % x3_2
    for k=31:32 % the negative parts
       x3_2(n)=x3_2(n)+a3(k)*exp(1j*(k-33)*2*pi/32*n);
    end
    for k=1:3 % the positive parts
        x3_2(n)=x3_2(n)+a3(k)*exp(1j*(k-1)*2*pi/32*n);
    end
end
x3_2=circshift(x3_2,1);
x3_2r=real(x3_2); % ignore the very small imainary part

for n=1:32 % x3_8
    for k=25:32 % the negative parts
       x3_8(n)=x3_8(n)+a3(k)*exp(1j*(k-33)*2*pi/32*n);
    end
    for k=1:9 % the positive parts
        x3_8(n)=x3_8(n)+a3(k)*exp(1j*(k-1)*2*pi/32*n);
    end
end
x3_8=circshift(x3_8,1);
x3_8r=real(x3_8);

for n=1:32 % x3_12
    for k=21:32 % the negative parts
       x3_12(n)=x3_12(n)+a3(k)*exp(1j*(k-33)*2*pi/32*n);
    end
    for k=1:13 % the positive parts
        x3_12(n)=x3_12(n)+a3(k)*exp(1j*(k-1)*2*pi/32*n);
    end
end
x3_12=circshift(x3_12,1);
x3_12r=real(x3_12);

for n=1:32 % x3_all
    for k=1:32 % the positive and negative parts
        x3_all(n)=x3_all(n)+a3(k)*exp(1j*(k-1)*2*pi/32*n);
    end
end
x3_all=circshift(x3_all,1);
x3_allr=real(x3_all);

% plots
figure;
subplot(5,1,1); % x3_2[n]
stem(nx,x3_2r);
xlabel('n');
ylabel('x3_2[n]','Interpreter','none');
axis([0,31,-inf,inf]);

subplot(5,1,2); % x3_8[n]
stem(nx,x3_8r);
xlabel('n');
ylabel('x3_8[n]','Interpreter','none');
axis([0,31,-inf,inf]);

subplot(5,1,3); % x3_12[n]
stem(nx,x3_12r);
xlabel('n');
ylabel('x3_12[n]','Interpreter','none');
axis([0,31,-inf,inf]);

subplot(5,1,4); % x3_all[n]
stem(nx,x3_allr);
xlabel('n');
ylabel('x3_all[n]','Interpreter','none');
axis([0,31,-inf,inf]);

subplot(5,1,5); % x3[n]
stem(nx,x3);
xlabel('n');
ylabel('x3[n]');
axis([0,31,-inf,inf]);