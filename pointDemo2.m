

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

azimuth_cipic = [-80 -65 -55 -45:5:45 55 65 80];%azimuth(13)==0 
azimuth=65;
azimuth_index=find(azimuth_cipic==azimuth);%获取65度方位角 的索引值

elevation_cipic=-45:360/64:235;
elevation=0;
elevation_index=find(elevation_cipic==elevation);%获取0度高度角 的索引值

subject_index=1;%cipic subject的索引

%读取azimuth=65，elevation=0的 hrir数据
hrtf_l= readCipicHrtf(subject_index,azimuth_index,elevation_index,'l');
hrtf_r= readCipicHrtf(subject_index,azimuth_index,elevation_index,'r');

wav_file_name='E:\Matlab\CipicHrtfApplication\InputWav\es01.wav';
[wav_data fs nbits]=wavread(wav_file_name);
%卷积生成双耳信号
binarual_l=filter(hrtf_l,1,wav_data);
binarual_r=filter(hrtf_r,1,wav_data);

binarual_output=[binarual_l binarual_r];

output_wav_file='E:\Matlab\CipicHrtfApplication\OutputWav\es01_point_binarual.wav';
wavwrite(binarual_output,fs,nbits,output_wav_file);

