function channelCodes = channelencode(sourceCodes, n, k)
% CHANNELENCODE 信道编码，采用(15,7)BCH码
% 输入参数：
%    sourceCodes: 信源编码序列
%    n: 每组编码长度
%    k：每组信息位长度
% 输出参数：
%    channelCodes: 完成后的信道编码

% 信道编码
N = length(sourceCodes); % 信源编码序列长度
blocks = ceil(N/k); % 需要分成的组数
if (blocks>N/k)
    sourceCodes(N:blocks*k) = 0; % 若不够，则补0
end
sourceCodes = gf(reshape(sourceCodes, k, blocks)'); % 转成blocks*k的矩阵
gfCodes = bchenc(sourceCodes, n, k); % BCH编码(GF域）
channelCodes = double(gfCodes.x); % BCH编码(实数域)
channelCodes = reshape(channelCodes', [], 1); % 转成列向量

% % 将数据写入文件
% fp = fopen('../data/ChannelEncode.txt','w');
% fprintf(fp, '信源编码序列码长: %d\n', N);
% fprintf(fp, '信道编码序列码长: %d\n', length(channelCodes));
% fprintf(fp, '编码速率: %f\n', k/n);
% fprintf(fp, '\n');
% fprintf(fp, '信道编码结果: ');
% for i = 1:length(channelCodes)
%     fprintf(fp, '%d', channelCodes(i)); % 信道编码结果
% end
    
end