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
for nn = 1:7
    Code = Bcodes(:,nn);
    MFR = real(ifft(Code.*data));% 完成循环卷积
    plot(mean(MFR(:,1:end/2),2))
    hold on
    plot(mean(MFR(:,ceil(end/2):end),2))
    hold off
    title(num2str(nn))
    legend('前一半时间求和','后一半时间求和')
%     pause(0.5)
    y = mean(MFR,2);
    p=find(y>6*rms(y),1);
    if ~isempty(p)
    result(nn,1:3) = [p,y(p),rms(y((1:end)~=p))];
    end
    end
% strong 1 3 5
% weak 7 15 19? 

pos = find(result(:,1));
pos = reshape(pos,[],1);
output = [pos result(pos,:)];
output(:,3) = output(:,3)./output(:,4);
output(:,4) = log10(normcdf(-output(:,3)));
output(:,2) = output(:,2)/51.15;

Title = [{'卫星编号'},{'延时(μs)'},{'相对强度'},{'差错概率(log10)'}];
output = [Title;mat2cell(output,ones(size(output,1)),ones(size(output,2)))]

