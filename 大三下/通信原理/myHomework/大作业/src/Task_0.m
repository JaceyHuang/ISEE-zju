clc
clear
close all

%% Parameters
M = 8;                                  % 8-ary
r = 1;                                  % minimum distance
L_data = 3*1e6;                         % length of data
L_symbol = L_data/log2(M);              % length of symbols
prob = [0.2, 0.3, 0.1, 0.1, ...
        0.12,0.08,0.05,0.05];           % a priori probability
% SNR
EsN0_dB = 18:0.4:20.4;                  % Es/N0,dB
EsN0 = 10.^(EsN0_dB/10);                % Es/N0
error = zeros(1,length(EsN0_dB));       % initialize the symbol errors
ser = zeros(1,length(EsN0_dB));         % initialize the SER in simulation
tser_8ary = zeros(1,length(EsN0_dB));   % initialize the theoretical SER

%% Decision Region
rand_pts = -5+10*rand(1,2500)+1i*(-5+10*rand(1,2500)); % generate random points
send_set = [r+0j,r-r*1j,0-r*1j,-r+0j,...
            0+r*1j,r+r*1j,2*r+2*r*1j, 2*r-2*r*1j];     % Constellation (0)

distance = zeros(1,M);
figure 
for t = 1:length(rand_pts)
    for w = 1:M
        distance(w) = norm(rand_pts(t) - send_set(w))^2; % Minimum Distance Detector 
    end
    hold on
    pos = find(distance == min(distance));               % classify and assign color
    if pos == 1
        h1 = plot(real(rand_pts(t)),imag(rand_pts(t)),'ro','Markersize',5);
    elseif pos == 2
        h2 = plot(real(rand_pts(t)),imag(rand_pts(t)),'go','Markersize',5);
    elseif pos == 3
        h3 = plot(real(rand_pts(t)),imag(rand_pts(t)),'bo','Markersize',5);
    elseif pos == 4
        h4 = plot(real(rand_pts(t)),imag(rand_pts(t)),'mo','Markersize',5);
    elseif pos == 5
        h5 = plot(real(rand_pts(t)),imag(rand_pts(t)),'g*','Markersize',5);
    elseif pos == 6
        h6 = plot(real(rand_pts(t)),imag(rand_pts(t)),'b*','Markersize',5);
    elseif pos == 7
        h7 = plot(real(rand_pts(t)),imag(rand_pts(t)),'m+','Markersize',5);
    elseif pos == 8
        h8 = plot(real(rand_pts(t)),imag(rand_pts(t)),'co','Markersize',5);
    end
end
ax = gca;
ax.XAxisLocation = 'origin';                    % set the intersection of 
ax.YAxisLocation = 'origin';                    % the axis to be the origin
legend([h1(1),h2(1),h3(1),h4(1),h5(1),h6(1),h7(1),h8(1)],...
        'S1','S2','S3','S4','S5','S6','S7','S8') % legend

%% 8-ary Modulation
send_set = [r+0j,r-r*1j,0-r*1j,-r+0j,...
            0+r*1j,r+r*1j,2*r+2*r*1j, 2*r-2*r*1j];    % Constellation (0)
send = randsrc(1,L_symbol,[send_set;prob]);           % symbols sent
% priori probability
Es_avg = sum(abs(send_set).^2 .* prob); % Es
N0 = Es_avg ./ EsN0;                    % N0

for q = 1:length(EsN0_dB)
    % noise
    noise = sqrt(N0(q)/2)*randn(1,L_symbol) + 1j*sqrt(N0(q)/2)*randn(1,L_symbol); % AWGN
    receive = (send + noise);           % symbols received
    detect = zeros(1,L_symbol);         % initialize symbols detected
    distance = zeros(1,M);              % initialize distances
    for t = 1:L_symbol
        for w = 1:M
            distance(w) = norm(receive(t) - send_set(w))^2; % Minimum Distance Detector 
        end
        pos = find(distance == min(distance));  % position of the corresponding signal 
        detect(t) = send_set(pos);              % demodulated symbols
        if (detect(t) ~= send(t)) 
            error(q) = error(q) + 1;            % number of error symbols
        end
    end
    ser(q) = error(q)/L_symbol;                        % 8-ary simulated SER
    tser_8ary(q) = 1.38*qfunc(sqrt(EsN0(q)/4.16))+...
                   0.3*qfunc(sqrt(EsN0(q)/2.08));      % 8-ary theoretical SER
end
figure
semilogy(EsN0_dB,ser,'o',EsN0_dB,tser_8ary,'b');       % plot 
grid on;                                               % grid
axis([18 20 3*10^-7 10^-4])                            % limit axis
xlabel('Es/N0 (dB)');                                  % x-axis
ylabel('SER');                                         % y-axis
legend('8-ary simulated SER','8-ary theoretical SER'); % legend
