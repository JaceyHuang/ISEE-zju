function modulatedCodes = modulation(channelCodes)
% MODULATION 调制，采用BPSK
% 输入参数： 
%    channelCodes: 信道编码序列 
% 输出参数：
%    modulatedCodes: 调制后的编码

modulatedCodes = 1-2*channelCodes; % BPSK调制

% 绘图
% scatterplot(modulatedCodes);

end