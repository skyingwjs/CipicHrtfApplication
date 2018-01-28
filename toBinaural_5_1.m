clear all;
clc;
subject=1;
framesize=1024;
azimuth_cipic = [-80 -65 -55 -45:5:45 55 65 80];%在cipic库中的index 1:25
elevation_cipic=-45:360/64:235; %在cipic库中的索引1:50
%azimuth elevation 两者长度一致
azimuth_front=[-30 30 0 0];%5.1系统前方4个扬声器在cipic库下的方位角
elevation_front=[0 0 0 0];%5.1系统前方4个扬声器在cipic库下的高度角

azimuth_front_index=zeros(1,4);
elevation_front_index=zeros(1,4);
%前方4个扬声器的 azimuth elevation 的index 这4个扬声器对应的HRIR数据从CIPIC库中读出来
%后方两个扬声器的HRIR数据要从插值的excel表中读出 
for i=1:length(azimuth_front)
    azimuth_front_index(i)=find(azimuth_cipic==azimuth_front(i));
   elevation_front_index(i)=find(elevation_cipic==elevation_front(i));
end
%6个扬声器所在位置对应的左右耳 hrir数据
hrir_data_l=zeros(200,6);
hrir_data_r=zeros(200,6);
%前方4个扬声器的 hrir数据 直接从cipic库中取出
for i=1:4
    hrir_data_l(:,i)=readCipicHrtf(subject,azimuth_front_index(i), elevation_front_index(i), 'l');
    hrir_data_r(:,i)=readCipicHrtf(subject,azimuth_front_index(i), elevation_front_index(i), 'r');
end

%后方两个扬声器的hrir数据从excel表的插值数据 中取出
xls_file_name='.\水平方位(0~360度1度间隔)Hrtf_L插值结果.xls';
sheet_name='subject1singleHrtf_L_C';
rangle_left_back='L205:L404';        %定位 左后方 -70度 hrir数据 在excel表中的位置   左耳
rangle_right_back='EV205:EV404';        %定位 右后方 70度 hrir数据 在excel表中的位置  左耳
hrir_data_l(:,5)=xlsread(xls_file_name,sheet_name,rangle_left_back);
hrir_data_l(:,6)=xlsread(xls_file_name,sheet_name,rangle_right_back);

xls_file_name='.\水平方位(0~360度1度间隔)Hrtf_R插值结果.xls';
sheet_name='subject1singleHrtf_R_C';
rangle_left_back='L205:L404';           %定位 左后方 -70度 hrir数据 在excel表中的位置   右耳
rangle_right_back='EV205:EV404';            %定位 右后方 70度 hrir数据 在excel表中的位置   右耳
hrir_data_r(:,5)=xlsread(xls_file_name,sheet_name,rangle_left_back);
hrir_data_r(:,6)=xlsread(xls_file_name,sheet_name,rangle_right_back);

%输入输出文件路径
input_file_path='.\InputWav\';
output_file_path='.\OutputWav\';
%input_wav_files_L 文件名数组  6个文件 依次存放
for i=1:6
     input_wav_files_L{i}=strcat(input_file_path,'pcm_mps_44khz_HQ_', int2str(i), '.wav');
end

wav_data_length=0;
framenumber=0;
for i=1:6
    %读取左右扬声器对应的wav文件
    [wav_data fs nbits]=wavread(input_wav_files_L{i});   
    %只在第一读取wav文件的时候计算wav_data的长度和帧数
    if i==1
        wav_data_length=length(wav_data);
        framenumber = floor(length(wav_data) / framesize);
    end  
    %卷积生成双耳信号
    binaural_data_l(:,i)=filter(hrir_data_l(:,i), 1,wav_data);%6个扬声器产生的左耳信号
    binaural_data_r(:,i)=filter(hrir_data_r(:,i), 1,wav_data);% 6个扬声器产生的右耳信号       
end   
 

    % 6个 扬声器产生的双耳信号 在频域叠加  反变换得到时域 
    for j = 1:framenumber
            out_data_l(((j-1)*framesize+1):j*framesize) = ifft( +...
                fft( binaural_data_l( ((j-1)*framesize+1):j*framesize,1) ) +...
                fft( binaural_data_l( ((j-1)*framesize+1):j*framesize,2)) +...         
                fft( binaural_data_l( ((j-1)*framesize+1):j*framesize,3)) +...
                fft( binaural_data_l( ((j-1)*framesize+1):j*framesize,4)) +...
                fft( binaural_data_l( ((j-1)*framesize+1):j*framesize,5)) +...
                fft( binaural_data_l( ((j-1)*framesize+1):j*framesize,6)) ); % 6扬声器左耳信号叠加    
            
               out_data_r(((j-1)*framesize+1):j*framesize) = ifft( +...
                fft( binaural_data_r( ((j-1)*framesize+1):j*framesize,1)) +...
                fft( binaural_data_r( ((j-1)*framesize+1):j*framesize,2)) +...         
                fft( binaural_data_r( ((j-1)*framesize+1):j*framesize,3)) +...
                fft( binaural_data_r( ((j-1)*framesize+1):j*framesize,4)) +...
                fft( binaural_data_r( ((j-1)*framesize+1):j*framesize,5)) +...
                fft( binaural_data_r( ((j-1)*framesize+1):j*framesize,6)) ); % 6扬声器右耳信号叠加    
            
    end

out_data=[out_data_l' out_data_r'];
% 输出文件
output_file_name=[output_file_path 'pcm_mps_44khz_HQ_binaural.wav'];
wavwrite(out_data,fs,nbits,output_file_name);









