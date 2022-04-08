function channelDecodes = channeldecode(demodulatedCodes, n, k, sourceCodes)
% CHANNELDECODE 信道解码，采用(15,7)BCH码
% 输入参数：
%    demodulatedCodes: 解调后的编码序列
%    n: 每组编码长度
%    k：每组信息位长度
% 输出参数：
%    channelDecodes: 完成信道解码后的编码序列

% 信道解码
blocks = length(demodulatedCodes)/n; % 需要分成的组数
demodulatedCodes = gf(reshape(demodulatedCodes, n, blocks)'); % 转成blocks*n的矩阵
gfCodes = bchdec(demodulatedCodes, n, k); % BCH解码(GF域）
channelDecodes = double(gfCodes.x); % BCH编码(实数域)
channelDecodes = reshape(channelDecodes', [], 1); % 转成列向量
channelDecodes = channelDecodes(1:length(sourceCodes)); % 去除补0的值

[numerrs, ratio] = biterr(channelDecodes, sourceCodes); % 计算误码数和误码率

% % 将数据写入文件
% fp = fopen('../data/ChannelDecode.txt','w');
% fprintf(fp, '误码数: %d\n', numerrs);
% fprintf(fp, '误码率: %f\n', ratio);
% fprintf(fp, '\n');
% fprintf(fp, '信道解码结果: ');
% for i = 1:length(channelDecodes)
%     fprintf(fp, '%d', channelDecodes(i)); % 信道解码结果
% end

end