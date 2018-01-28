clear all;
clc;

% CIPIC高度角分布 共50个 从-45到235    分布图见ReadMe.doc
% elevation_cipic=-45:360/64:235;  
% elevation(9)==0 是正前方高度角    elevation(25)==90是正上方高度角   elevation(41)==180是正后方高度角
% elevation_index=1:50;   %对应高度角在CIPIC Hrtf库中的索引

% CIPIC 方位角分布 共50个  前后方各25个   分布图见ReadMe.doc
% azimuth_cipic = [-80 -65 -55 -45:5:45 55 65 80];  
% azimuth(13)==0正前方方位角
% azimuth_index=1:25;

%azimuth 前方环绕  从-80度到80度  索引值1:25
azimuth_cipic = [-80 -65 -55 -45:5:45 55 65 80];
azimuth_index=1:25;

elevation_cipic=-45:360/64:235;
elevation=0;
elevation_index_at0=find(elevation_cipic==elevation);%获取0度高度角 的索引值 ：9
elevation_index=elevation_index_at0*ones(1,25);%与azimuth_index长度一致 25个 

subject_index=1;%cipic subject的索引
%读取wav文件   分帧
wav_file_name='E:\Matlab\CipicHrtfApplication\InputWav\es01.wav';
[wav_data fs nbits]=wavread(wav_file_name);

framenumber = 25;%25帧  对应25个方位角
framesize=floor(length(wav_data) / framenumber);%每帧的数据点的个数

for i=1:length(azimuth_cipic)
    %读取azimuth_cipic(i)     elevation==0 subject_index==1 对应的hrir
    hrtf_l= readCipicHrtf(subject_index,azimuth_index(i),elevation_index(i),'l');
    hrtf_r= readCipicHrtf(subject_index,azimuth_index(i),elevation_index(i),'r');
    wav_data_temp=wav_data((framesize*(i-1)+1):framesize*i);
    %卷积生成双耳信号
    binarual_l=filter(hrtf_l,1,wav_data_temp);
    binarual_r=filter(hrtf_r,1,wav_data_temp);
    %连接各帧生成的双耳信号
    if i==1
         binarual_output=[binarual_l,binarual_r];
    else
        binarual_output=vertcat(binarual_output,[binarual_l,binarual_r]);
    end
end

%输出双耳信号
output_wav_file='E:\Matlab\CipicHrtfApplication\OutputWav\es01_surround_binarual.wav';
wavwrite(binarual_output,fs,nbits,output_wav_file);

