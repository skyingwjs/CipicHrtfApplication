clear all;
clc;
subject=9;
framesize=1024;
azimuth_cipic = [-80 -65 -55 -45:5:45 55 65 80];%在cipic库中的index 1:25
elevation_cipic=-45:360/64:235; %在cipic库中的索引1:50
%azimuth elevation 两者长度一致性
azimuth=[0 -45 -80 -65 -30 0 30 65 80 45 ];%22.2 系统中间层扬声器位置分布   azimuth中的每个元素必须来自于azimuth_cipic
elevation=[180 180 180 0 0 0 0 0 180 180];%前方 高度角为0  后方高度角为180    elevation中的每个元素必须来自于elevation_cipic
azimuth_length=length(azimuth);
azimuth_index=zeros(1,length(azimuth));
elevation_index=zeros(1,length(elevation));

for i=1:length(azimuth)
    azimuth_index(i)=find(azimuth_cipic==azimuth(i));
   elevation_index(i)=find(elevation_cipic==elevation(i));
end

input_file_path='E:\Matlab\CipicHrtfApplication\InputWav\';
output_file_path='E:\Matlab\CipicHrtfApplication\OutputWav\';
%input_wav_files_L 文件名数组
for i=1:10
    if (i>=10)
        input_wav_files_L{i}=strcat(input_file_path,'es01_L_', int2str(i), '.wav');
        break;
    end
    input_wav_files_L{i}=strcat(input_file_path,'es01_L_0', int2str(i),'.wav');
end

for i=1:10
    if (i>=10)
        input_wav_files_R{i}=strcat(input_file_path,'es01_R_', int2str(i), '.wav');
        break;
    end
       input_wav_files_R{i}=strcat(input_file_path,'es01_R_0', int2str(i),'.wav');
end

for i=1:azimuth_length
    %读取左右扬声器对应的wav文件
    [wav_data_l fs nbits]=wavread(input_wav_files_L{i});
    [wav_data_r fs nbits]=wavread(input_wav_files_R{i});          

    wav_data_length=length(wav_data_l);
    framenumber = floor(length(wav_data_l) / framesize);
    
    %读取左右扬声器所在角度对应的左右耳hrir数据    
    hrir_data_ll=readCipicHrtf(subject,azimuth_index(i), elevation_index(i),'l');%左扬声器 左耳 Hrir 数据
    hrir_data_lr=readCipicHrtf(subject,azimuth_index(i), elevation_index(i),'r');%左扬声器 右耳 Hrir 数据   
    
    if i==azimuth_length
            hrir_data_rl=readCipicHrtf(subject,azimuth_index(1), elevation_index(1),'l');%右扬声器 左耳 Hrir 数据    
            hrir_data_rr=readCipicHrtf(subject,azimuth_index(1), elevation_index(1),'r'); %右扬声器 右耳 Hrir 数据   
    else
            hrir_data_rl=readCipicHrtf(subject,azimuth_index(i+1), elevation_index(i+1),'l');%右扬声器 左耳 Hrir 数据    
            hrir_data_rr=readCipicHrtf(subject,azimuth_index(i+1), elevation_index(i+1),'r'); %右扬声器 右耳 Hrir 数据   
    end

    %卷积生成双耳信号
    binaural_data_ll=filter(hrir_data_ll, 1,wav_data_l);%左扬声器产生的左耳信号
    binaural_data_lr=filter(hrir_data_lr, 1,wav_data_l);% 左扬声器产生的右耳信号   
    binaural_data_rl=filter(hrir_data_rl, 1,wav_data_r); %右扬声器产生的左耳信号  
    binaural_data_rr=filter(hrir_data_rr, 1,wav_data_r); %右扬声器产生的右耳信号    
    
    %%每次循环 必须重新声明这两个变量 
    binaural_data_l=zeros(length(wav_data_l),1);
    binaural_data_r=zeros(length(wav_data_l),1);
    %频域叠加  反变换得到时域 
    for j = 1:framenumber
            binaural_data_l(((j-1)*framesize+1):j*framesize) = ifft(fft( binaural_data_ll( ((j-1)*framesize+1):j*framesize) ) +...
                fft( binaural_data_rl( ((j-1)*framesize+1):j*framesize) )); % 两扬声器左耳信号叠加    
            
            binaural_data_r(((j-1)*framesize+1):j*framesize) = ifft(fft( binaural_data_lr( ((j-1)*framesize+1):j*framesize) ) +...
                fft( binaural_data_rr( ((j-1)*framesize+1):j*framesize) )); % 两扬声器右耳信号 叠加   
    end

    %处理 最后不足一帧的 尾部数据
                binaural_data_l(framenumber*framesize+1:wav_data_length) = ifft(   fft( binaural_data_ll( framenumber*framesize+1:wav_data_length)) +...
                fft( binaural_data_rl( framenumber*framesize+1:wav_data_length))   ); % 两扬声器左耳信号 叠加     
            
                binaural_data_r(framenumber*framesize+1:wav_data_length) = ifft(    fft( binaural_data_lr( framenumber*framesize+1:wav_data_length )) +...
                fft( binaural_data_rr( framenumber*framesize+1:wav_data_length))   ); % 两扬声器右耳信号  叠加  

   %连接双耳信号
   if i==1
       output_wav_data( (wav_data_length*(i-1)+1):wav_data_length*i,   1)=binaural_data_l;
       output_wav_data( (wav_data_length*(i-1)+1):wav_data_length*i,   2)=binaural_data_r;   
   else
       output_wav_data=vertcat(output_wav_data, [binaural_data_l,binaural_data_r]);
   end  
   
end   

% 输出文件
output_file_name=[output_file_path 'es01_binaural.wav'];
wavwrite(output_wav_data,fs,nbits,output_file_name);









