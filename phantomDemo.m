%% 两扬声器（30 100）在65处生成虚拟声源
clc;
clear all;
virtual_sound_azimuth=65;%虚拟声源角度
%左右扬声器角度   扬声器角度坐标系：人头正前方为0度，顺时针旋转到360度
loudspeaker_l=30;
loudspeaker_r=100;

azimuth_cipic = [-80 -65 -55 -45:5:45 55 65 80];%azimuth(13)==0 
%左右扬声器角度 在cipic库坐标系下的  方位角角度 30度在前方 80度在后方  
%获得azimuth的索引值
azimuth=[30 80];
azimuth_index=zeros(1,length(azimuth));
for i=1:length(azimuth)
    azimuth_index(i)=find(azimuth_cipic==azimuth(i));
end

%左右扬声器角度 在cipic库坐标系下的  方位角角度   0度在正前方 180度在正后方  
%获得elevation的索引值
elevation_cipic=-45:360/64:235;
elevation=[0 180];
elevation_index=zeros(1,length(elevation));
for i=1:length(elevation)
    elevation_index(i)=find(elevation_cipic==elevation(i));
end  

subject_index=1;

%读取输入的音频文件
wav_file_name='E:\Matlab\CipicHrtfApplication\InputWav\es01.wav';
[wav_data fs nbits]=wavread(wav_file_name);
framesize=1024;
framenumber = floor(length(wav_data) / framesize);

%gl gr为左右扬声器信号的增益
gl = zeros(size(virtual_sound_azimuth,1),1);
gr = gl;

%由正切定律 求gl gr
theta = (loudspeaker_r - loudspeaker_l) / 2;  %偏移角度
azi =virtual_sound_azimuth- 0.5 * (loudspeaker_r+ loudspeaker_l);
temp1=tan(theta*pi/180);  %tan(theta)
temp2=tan(azi*pi/180); %tan(phi)
gl = (temp1 - temp2) / sqrt(2*temp1.^2 + 2*temp2.^2);
gr= (temp1 + temp2) / sqrt(2*temp1.^2 + 2*temp2.^2);          

%%加载HRTF数据
hrtf_loudspeaker_ll= readCipicHrtf(subject_index,azimuth_index(1),elevation_index(1),'l');%左扬声器左耳hrir数据
hrtf_loudspeaker_lr=  readCipicHrtf(subject_index,azimuth_index(1),elevation_index(1),'r');%左扬声器右耳hrir数据
hrtf_loudspeaker_rl= readCipicHrtf(subject_index,azimuth_index(2),elevation_index(2),'l');%右扬声器左耳hrir数据
hrtf_loudspeaker_rr=  readCipicHrtf(subject_index,azimuth_index(2),elevation_index(2),'r');  %右扬声器右耳hrir数据  
%%左右扬声器信号 乘以对应的增益
dataL = wav_data * gl;
dataR = wav_data * gr;

%%计算两扬声器形成的双耳信号
outLL = zeros(length(wav_data),1); %% LL代表左扬声器在左耳的信号
outLR = zeros(length(wav_data),1); %% LR代表左扬声器在右耳的信号
outRL = zeros(length(wav_data),1);
outRR = zeros(length(wav_data),1);
%卷积生成双耳信号
outLL= filter(hrtf_loudspeaker_ll,1,dataL);
outLR= filter(hrtf_loudspeaker_lr,1,dataL);
outRL= filter(hrtf_loudspeaker_rl,1,dataR);
outRR= filter(hrtf_loudspeaker_rr,1,dataR);
%变换到频域叠加 然后反变换到时域
for j = 1:framenumber
            outL(((j-1)*framesize+1):j*framesize) = ifft(fft( outLL( ((j-1)*framesize+1):j*framesize) ) +...
                fft( outRL( ((j-1)*framesize+1):j*framesize) )); % 两扬声器左耳信号    %fft变换要1024点
            outR(((j-1)*framesize+1):j*framesize) = ifft(fft( outLR( ((j-1)*framesize+1):j*framesize) ) +...
                fft( outRR( ((j-1)*framesize+1):j*framesize) )); % 两扬声器右耳信号    
end
out_data=[outL' outR'];

output_wav_file='E:\Matlab\CipicHrtfApplication\OutputWav\es01_phantom_binarual.wav';
wavwrite(out_data ,fs,nbits,output_wav_file);

