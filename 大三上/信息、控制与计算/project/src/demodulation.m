function demodulatedCodes = demodulation(transmittedCodes, channelCodes)
% DEMODULATION BPSK解调
% 输入参数：
%    transmittedCodes: 通过高斯信道后的信号序列
% 输出参数：
%    transmittedCodes: 解调后的序列
 
% 判决
tempCodes(transmittedCodes>-0) = 1;
tempCodes(transmittedCodes<0) = -1; 
% 解调
demodulatedCodes(tempCodes>-0) = 0; 
demodulatedCodes(tempCodes<0) = 1; 
% 转成列向量
demodulatedCodes = reshape(demodulatedCodes,[],1); 

[numerrs, ratio] = biterr(demodulatedCodes, channelCodes); % 计算误码数和误码率

% % 将数据写入文件
% fp = fopen('../data/demodulation.txt','w');
% fprintf(fp, '误码数: %d\n', numerrs);
% fprintf(fp, '误码率: %f\n', ratio);
% fprintf(fp, '\n');
% fprintf(fp, '解调结果: ');
% for i = 1:length(demodulatedCodes)
%     fprintf(fp, '%d', demodulatedCodes(i)); % 解调结果
% end

end