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
send_set = [r+0j,r-r*1j,0-r*1j,-r+0j,...
            0+r*1j,r+r*1j,2*r+2*r*1j, 2*r-2*r*1j];    % Constellation (0)
        
%% Decision Region
visual_decision_region(send_set, prob)