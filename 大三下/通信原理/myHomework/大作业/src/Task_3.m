clc
clear
close all

%% Parameters
M = 8;                                  % 8-ary
r = 1;                                  % minimum distance
L_bits = 3*1e6;                         % length of data
L_symbol = L_bits/log2(M);              % length of symbols
prob = [0.2, 0.3, 0.1, 0.1, ...
        0.12,0.08,0.05,0.05];           % a priori probability
% SNR
EsN0_dB = 18:0.4:20.4;                    % Es/N0,dB
EsN0 = 10.^(EsN0_dB/10);                  % Es/N0
error = zeros(1,length(EsN0_dB));         % initialize the bit errors
ber_bst = zeros(1,length(EsN0_dB));       % initialize the BER in simulation using the best scheme
ber_ran = zeros(1,length(EsN0_dB));       % initialize the BER in simulation using random labeling
tber_8ary_bst = zeros(1,length(EsN0_dB)); % initialize the theoretical BER using the best scheme
tber_8ary_ran = zeros(1,length(EsN0_dB)); % initialize the theoretical BER using random labeling

%% 8-ary modulation
send_set = [r+0j,r-r*1j,0-r*1j,-r+0j,...
            0+r*1j,r+r*1j,2*r+2*r*1j, 2*r-2*r*1j]; % Constellation (0)
send = randsrc(1,L_symbol,[send_set;prob]);        % symbols sent
bits_bst = zeros(1,L_bits);                        % initialize the bit sequence using the best scheme
bits_ran = zeros(1,L_bits);                        % initialize the bit sequence using random labeling
code = [0,0,0;0,0,1;0,1,1;0,1,0;...
        1,1,0;1,1,1;1,0,1;1,0,0];                  % Gray code

Es_avg = sum(abs(send_set).^2 .* prob); % Es
N0 = Es_avg ./ EsN0;                    % N0

%% mapping using best scheme and random labeling
for q = 1:L_symbol
    if (send(q) == send_set(1))
        bits_bst(3*q-2:3*q) = code(1);          % 000 => r+0j,the best scheme
        bits_ran(3*q-2:3*q) = code(1);          % 000 => r+0j,random labeling
    elseif (send(q) == send_set(2))
        bits_bst(3*q-2:3*q) = code(4);          % 010 => r-r*j,the best scheme
        bits_ran(3*q-2:3*q) = code(2);          % 001 => r-r*j,random labeling
    elseif (send(q) == send_set(3))
        bits_bst(3*q-2:3*q) = code(3);          % 011 => 0-r*j,the best scheme
        bits_ran(3*q-2:3*q) = code(3);          % 011 => 0-r*j,random labeling
    elseif (send(q) == send_set(4))
        bits_bst(3*q-2:3*q) = code(6);          % 111 => -r+0j,the best scheme
        bits_ran(3*q-2:3*q) = code(4);          % 010 => -r+0j,random labeling
    elseif (send(q) == send_set(5))
        bits_bst(3*q-2:3*q) = code(7);          % 101 => 0+r*j,the best scheme
        bits_ran(3*q-2:3*q) = code(5);          % 110 => 0+r*j,random labeling
    elseif (send(q) == send_set(6))
        bits_bst(3*q-2:3*q) = code(2);          % 001 => r+r*j,the best scheme
        bits_ran(3*q-2:3*q) = code(6);          % 111 => r+r*j,random labeling
    elseif (send(q) == send_set(7))
        bits_bst(3*q-2:3*q) = code(8);          % 100 => 2r+2r*j,the best scheme
        bits_ran(3*q-2:3*q) = code(7);          % 101 => 2r+2r*j,random labeling
    else
        bits_bst(3*q-2:3*q) = code(5);          % 110 => 2r-2r*j,the best scheme
        bits_ran(3*q-2:3*q) = code(8);          % 100 => 2r-2r*j,random labeling
    end
end
for q = 1:length(EsN0_dB)
    % ÔëÉù noise
    noise = sqrt(N0(q)/2)*randn(1,L_symbol) + 1j*sqrt(N0(q)/2)*randn(1,L_symbol); % AWGN
    receive = (send + noise);           % symbols received
    detect = zeros(1,L_symbol);         % initialize detected symbols
    detect_bits_bst = zeros(1,L_bits);  % initialize detected bits of the best scheme
    detect_bits_ran = zeros(1,L_bits);  % initialize detected bits of random labeling
    distance = zeros(1,M);              % initialize the distances
    value = zeros(1,M);                 % initialize values of the formula
    for t = 1:L_symbol
        for w = 1:M
            distance(w) = norm(receive(t) - send_set(w))^2; % distances
            value(w) = distance(w)-N0(q)*log(prob(w));      % values of the formula
        end
        pos = find(value == min(value));               % position of the corresponding signal by Optimal Detector
        detect(t) = send_set(pos);                     % demodulated symbols
        
        % mapping
        if (detect(t) == send_set(1))
            detect_bits_bst(3*t-2:3*t) = code(1);          % 000 => r+0j,the best scheme
            detect_bits_ran(3*t-2:3*t) = code(1);          % 000 => r+0j,random labeling
        elseif (detect(t) == send_set(2))
            detect_bits_bst(3*t-2:3*t) = code(4);          % 010 => r-r*j,the best scheme
            detect_bits_ran(3*t-2:3*t) = code(2);          % 001 => r-r*j,random labeling
        elseif (detect(t) == send_set(3))
            detect_bits_bst(3*t-2:3*t) = code(3);          % 011 => 0-r*j,the best scheme
            detect_bits_ran(3*t-2:3*t) = code(3);          % 011 => 0-r*j,random labeling
        elseif (detect(t) == send_set(4))
            detect_bits_bst(3*t-2:3*t) = code(6);          % 111 => -r+0j,the best scheme
            detect_bits_ran(3*t-2:3*t) = code(4);          % 010 => -r+0j,random labeling
        elseif (detect(t) == send_set(5))
            detect_bits_bst(3*t-2:3*t) = code(7);          % 101 => 0+r*j,the best scheme
            detect_bits_ran(3*t-2:3*t) = code(5);          % 110 => 0+r*j,random labeling
        elseif (detect(t) == send_set(6))
            detect_bits_bst(3*t-2:3*t) = code(2);          % 001 => r+r*j,the best scheme
            detect_bits_ran(3*t-2:3*t) = code(6);          % 111 => r+r*j,random labeling
        elseif (detect(t) == send_set(7))
            detect_bits_bst(3*t-2:3*t) = code(8);          % 100 => 2r+2r*j,the best scheme
            detect_bits_ran(3*t-2:3*t) = code(7);          % 101 => 2r+2r*j,random labeling
        else
            detect_bits_bst(3*t-2:3*t) = code(5);          % 110 => 2r-2r*j,the best scheme
            detect_bits_ran(3*t-2:3*t) = code(8);          % 100 => 2r-2r*j,random labeling
        end
    end
    [nerr_bst,ber_bst(q)] = biterr(bits_bst,detect_bits_bst);          % 8-ary simulated BER using the best scheme
    [nerr_ran,ber_ran(q)] = biterr(bits_ran,detect_bits_ran);          % 8-ary simulated BER using random labeling
    
    tber_8ary_bst(q) = prob(1)*(1/3*qfunc(sqrt(EsN0(q)/4.16)+log(2/3)*sqrt(1.04/EsN0(q))) + 1/3*qfunc(sqrt(EsN0(q)/4.16) +log(5/2) *sqrt(1.04/EsN0(q))))+...      
                       prob(2)*(1/3*qfunc(sqrt(EsN0(q)/4.16)+log(3/2)*sqrt(1.04/EsN0(q))) + 1/3*qfunc(sqrt(EsN0(q)/4.16) +log(3)   *sqrt(1.04/EsN0(q))))+...   
                       prob(3)*(1/3*qfunc(sqrt(EsN0(q)/4.16)+log(1/3)*sqrt(1.04/EsN0(q))))+...
                       prob(4)*(1/3*qfunc(sqrt(EsN0(q)/2.08))                             + 1/3*qfunc(sqrt(EsN0(q)/2.08) +log(5/6) *sqrt(0.52/EsN0(q))))+....
                       prob(5)*(1/3*qfunc(sqrt(EsN0(q)/4.16)+log(3/2)*sqrt(1.04/EsN0(q))))+...
                       prob(6)*(1/3*qfunc(sqrt(EsN0(q)/4.16)+log(2/5)*sqrt(1.04/EsN0(q))) + 1/3*qfunc(sqrt(EsN0(q)/4.16) +log(2/3) *sqrt(1.04/EsN0(q))))+....
                       prob(7)*(2/3*qfunc(sqrt(EsN0(q)/2.08)+log(5/8)*sqrt(0.52/EsN0(q))))+...
                       prob(8)*(1/3*qfunc(sqrt(EsN0(q)/2.08)+log(1/6)*sqrt(0.52/EsN0(q)))); % 8-ary theoretical BER using the best scheme
    tber_8ary_ran(q) = prob(1)*(1/3*qfunc(sqrt(EsN0(q)/4.16)+log(2/3)*sqrt(1.04/EsN0(q))) + 3/3*qfunc(sqrt(EsN0(q)/4.16) +log(5/2) *sqrt(1.04/EsN0(q))))+...      
                       prob(2)*(1/3*qfunc(sqrt(EsN0(q)/4.16)+log(3/2)*sqrt(1.04/EsN0(q))) + 1/3*qfunc(sqrt(EsN0(q)/4.16) +log(3)   *sqrt(1.04/EsN0(q))))+...   
                       prob(3)*(1/3*qfunc(sqrt(EsN0(q)/4.16)+log(1/3)*sqrt(1.04/EsN0(q))))+...
                       prob(4)*(1/3*qfunc(sqrt(EsN0(q)/2.08))                             + 1/3*qfunc(sqrt(EsN0(q)/2.08) +log(5/6) *sqrt(0.52/EsN0(q))))+....
                       prob(5)*(1/3*qfunc(sqrt(EsN0(q)/4.16)+log(3/2)*sqrt(1.04/EsN0(q))))+...
                       prob(6)*(3/3*qfunc(sqrt(EsN0(q)/4.16)+log(2/5)*sqrt(1.04/EsN0(q))) + 1/3*qfunc(sqrt(EsN0(q)/4.16) +log(2/3) *sqrt(1.04/EsN0(q))))+....
                       prob(7)*(1/3*qfunc(sqrt(EsN0(q)/2.08)+log(5/8)*sqrt(0.52/EsN0(q))))+...
                       prob(8)*(2/3*qfunc(sqrt(EsN0(q)/2.08)+log(1/6)*sqrt(0.52/EsN0(q)))); % 8-ary theoretical BER using random labeling
end

figure
semilogy(EsN0_dB,ber_bst,'bo',EsN0_dB,ber_ran,'r*',EsN0_dB,tber_8ary_bst,'b',EsN0_dB,tber_8ary_ran,'r');  % plot
grid on;                                               % grid
axis([18 20 10^-7 10^-4])                              % limit axis
xlabel('Es/N0 (dB)');                                  % x-axis
ylabel('BER');                                         % y-axis
legend('8-ary simulated BER using the best scheme','8-ary simulated BER using random labeling',...
       '8-ary theoretical BER using the best scheme','8-ary theoretical BER using random labeling');      % legend
