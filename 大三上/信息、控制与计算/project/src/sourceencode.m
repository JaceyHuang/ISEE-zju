function [sourceCodes, dict, K] = sourceencode(quantizedSignal, nQuantizationBits)
% SOURCEENCODE 信源编码，采用二元Huffman编码
% 输入参数：
%    quantizedSignal: 量化后的语音信号（离散无记忆信源的输出） 
% 输出参数：
%    sourceCodes: 完成后的信源编码

% 计算信源概率分布及信源熵
L = length(quantizedSignal); % 信源输出序列长度
symbols = unique(quantizedSignal); % 统计信源字符表
K = length(symbols); % 字符数
U = zeros(3,K); % 信源字符概率表
U(1,:) = symbols; % 第一行为字符
for i = 1:K
    U(2,i) = length(find(quantizedSignal==U(1,i))); % 第二行为出现次数
    U(3,i) = U(2,i)/L; % 第三行为出现概率
end
H = sum(-U(3,:).*log2(U(3,:))); % 信源熵

% Huffman编码
[dict, avglen] = huffmandict(U(1,:), U(3,:)); % 得到每个符号对应的码字及平均码长
sourceCodes = huffmanenco(quantizedSignal, dict); % 将信号中各符号替换为码字
R = avglen; % 编码速率
eta = H/R; % 编码效率
quantizedCodesLength = nQuantizationBits*L; % 量化8位编码序列码长
sourceCodesLength = length(sourceCodes); % Huffman编码序列码长
sourceCompressionRatio = quantizedCodesLength/sourceCodesLength; % 压缩率

% % 将数据写入文件
% fp = fopen('../data/SourceEncode.txt','w');
% fprintf(fp, '信源熵(熵速率): %f\n', H);
% fprintf(fp, '熵的相对率: %f\n', H/log2(K));
% fprintf(fp, '冗余度: %f\n', 1-H/log2(K));
% fprintf(fp, '平均码长: %f\n', avglen);
% fprintf(fp, '编码速率: %f\n', R);
% fprintf(fp, '编码效率: %f\n', eta);
% fprintf(fp, '量化8位编码序列码长: %d\n', quantizedCodesLength);
% fprintf(fp, 'Huffman编码序列码长: %d\n', sourceCodesLength);
% fprintf(fp, '压缩率: %f\n\n', sourceCompressionRatio);
% fprintf(fp, '符号                    码字\n');
% for i = 1:K
%     fprintf(fp,'%s   ', cell2mat(dict(i,1))); % 符号
%     for j = 1:length(dict{i,2})
%         fprintf(fp, '%d', dict{i,2}(j)); % 对应的码字
%     end
%     fprintf(fp, '\n');
% end
% fprintf(fp, '\n');
% fprintf(fp, '信源编码结果: ');
% for i = 1:length(sourceCodes)
%     fprintf(fp, '%d', sourceCodes(i)); % 信源编码结果
% end

end