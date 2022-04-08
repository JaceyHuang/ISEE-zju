function transmittedCodes = channeltransmission(modulatedCodes, SNR)
% CHANNELTRANSMISSION 信道传输，采用加性高斯噪声信道
% 输入参数：
%    modulatedCodes: 调制后的码字序列
%    SNR: 信道的信噪比(dB)
% 输出参数：
%    transmittedCodes: 通过信道传输后的序列

transmittedCodes = awgn(modulatedCodes, SNR); % 添加高斯白噪声

% 绘图
% h = scatterplot(modulatedCodes);
% scatterplot(transmittedCodes,[],[],'r*',h);

end