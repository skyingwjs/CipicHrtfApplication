function hrtf= readCipicHrtf(subject,Ia,Ie,channel)
%% Find path to hrir data files
data_path_head='.\CIPIC_HRTF_LIBRARY\subject_';
data_path_tail = '\hrir_final.mat';

subject_index = subject;
subject_numbers = sub_nums; % Load cell array of subject numbers from file
subject_string = subject_numbers{subject_index};

Fname = [data_path_head subject_string data_path_tail];

%% get the HRTF of azimuth&elevation    
load(Fname);
if(channel == 'l')    
    hl = hrir_l( Ia ,Ie,:);
    for i=1:200
        hrtf(i) = hl(i);
    end
elseif(channel == 'r')
    hr = hrir_r( Ia ,Ie,:);
    for i=1:200
        hrtf(i) = hr(i);
    end
end


