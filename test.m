dataLen = 10230*5*1000;% 全部数据
fid = fopen('UEQ_rawFile_16bit_Task2.dat','rb');
[data, count] = fread(fid, dataLen ,'int16');
load('B3I_Codes.mat')

%对PRN码进行预处理：先增加采样率（重复）至5倍，然进行傅立叶变换
Bcodes = reshape(B3I_Codes',1,[]);
Bcodes = repmat(Bcodes,5,1);
Bcodes = reshape(Bcodes,10230*5,[]);
Bcodes = conj(fft(Bcodes));% 匹配滤波需要将参考波形的频谱求复共轭

% data = data(10230*5*90+1:end); %选取部分数据
data = reshape(data,10230*5,[]); % 按循环进行排列，每个循环一行
data = fft(data);
result = zeros(63,3);
for nn = 1:63
    Code = Bcodes(:,nn);
    MFR = real(ifft(Code.*data));% 完成循环卷积
    plot(mean(MFR(:,1:end/2),2))
    hold on
    plot(mean(MFR(:,ceil(end/2):end),2))
    hold off
    title(num2str(nn))
    pause(0.5)
    y = mean(MFR,2);
    p=find(y>6*rms(y),1);
    if ~isempty(p)
    result(nn,1:2) = [p,y(p)];
    end
    end
% strong 1 3 5
% weak 7 15 19? 
