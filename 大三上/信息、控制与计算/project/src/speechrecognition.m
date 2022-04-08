function signal = speechrecognition(sourceDecodes, Fs)
% SPEECHRECOGNITION 语音识别
% 输入参数：
%    reconstructedSignal: 重构得到的语音信号
%    Fs: 采样频率
% 输出参数：
%    signal: 语音识别得到的指令

load('commandNet.mat'); % 加载该预训练网络
% 计算听觉频谱图
auditorySpect = helperExtractAuditoryFeatures(sourceDecodes, Fs);
% 根据听觉频谱图对命令进行分类
signal = classify(trainedNet, auditorySpect);

disp(signal); % 打印识别出的语音指令

% % 可视化数据
% info = audioinfo('../data/command.flac'); % 采样所得语音信号的信息
% t = 0:seconds(1/Fs):seconds(info.Duration); % 语音经过的时间
% t = t(1:end-1); figure;
% subplot(2,1,1); plot(t, sourceDecodes);
% axis tight; title(string(signal)); % 以识别出的指令作为标题
% subplot(2,1,2); pcolor(auditorySpect); % 伪彩图
% shading flat; title('听觉频谱图');

% % 将指令写入文件
% fp = fopen('../data/SpeechRecognition.txt','w');
% fprintf(fp, '语音指令为: %s\n', signal);

end