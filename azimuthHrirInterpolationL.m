clc;
clear all;
azimuth_cipic=[-80 -65 -55 -45:5:45 55 65 80];
elevation_cipic = -45:(360/64):235;
subject=1;
%待插值的方位角 
theta_front =-80:79;  %前方
theta_back = -80:79;  %后方
theta_left_center=[-80:-1:-90 -89:1:-79]  ;             %左中  后方开始
theta_right_center =[-80:-1:-90 -89:1:-79]  ;          %右中  后方开始
%待插值的角度的   方位角索引和高度角索引
Ia_front_one=zeros(length(theta_front),1);
Ia_front_two=zeros(length(theta_front),1);
Ie_front_one=zeros(length(theta_front),1);
Ie_front_two=zeros(length(theta_front),1);

%待插值的角度的   方位角索引和高度角索引
Ia_back_one=zeros(length(theta_back),1);
Ia_back_two=zeros(length(theta_back),1);
Ie_back_one=zeros(length(theta_back),1);
Ie_back_two=zeros(length(theta_back),1);

%待插值的角度的   方位角索引和高度角索引
Ia_left_center_one=zeros(length(theta_left_center),1);
Ia_left_center_two=zeros(length(theta_left_center),1);
Ie_left_center_one=zeros(length(theta_left_center),1);
Ie_left_center_two=zeros(length(theta_left_center),1);

%待插值的角度的   方位角索引和高度角索引
Ia_right_center_one=zeros(length(theta_right_center),1);
Ia_right_center_two=zeros(length(theta_right_center),1);
Ie_right_center_one=zeros(length(theta_right_center),1);
Ie_right_center_two=zeros(length(theta_right_center),1);


%%获得方位角高度角的索引值
for i=1:length(theta_front)
        for j=1:length(azimuth_cipic)
              if theta_front(i)>= azimuth_cipic(j)  
                  Ia_front_one(i)=find(azimuth_cipic==azimuth_cipic(j));
                  Ia_front_two(i)=find(azimuth_cipic==azimuth_cipic(j+1));
                  Ie_front_one(i)=9;
                  Ie_front_two(i)=9;
              end
        end
end

for i=1:length(theta_back)
        for j=1:length(azimuth_cipic)
              if theta_back(i)>= azimuth_cipic(j)  
                  Ia_back_one(i)=find(azimuth_cipic==azimuth_cipic(j));
                  Ia_back_two(i)=find(azimuth_cipic==azimuth_cipic(j+1));
                  Ie_back_one(i)=41;
                  Ie_back_two(i)=41;
              end
        end
end

for i=1:length(theta_left_center)
                  Ia_left_center_one(i)=1;
                  Ia_left_center_two(i)=1;
                  Ie_left_center_one(i)=41;
                  Ie_left_center_two(i)=9;
end

for i=1:length(theta_right_center)
                  Ia_right_center_one(i)=25;
                  Ia_right_center_two(i)=25;
                  Ie_right_center_one(i)=41;
                  Ie_right_center_two(i)=9;
end

single_one_hrir_l=zeros(200,360);% 端点1    HRIR数据
single_two_hrir_l=zeros(200,360);% 端点2    HRIR数据
single_factor_one=zeros(1,360);
single_factor_two=zeros(1,360);

single_two_hrir_l_C=zeros(200,360);%端点2 对齐的HRIR数据
single_hrir_l_NC=zeros(200,360);% 水平一圈的插值未对齐结果
single_hrir_l=zeros(200,360);
single_hrir_l_C=zeros(200,360);% 水平一圈的插值对齐结果

theta_start_index=1;
theta_end_index=length(theta_front) ;

%%前方插值结果
    for i=theta_start_index:theta_end_index     
        %%单线性——读取待插值点两端点的HRTF数据
        single_one_hrir_l(:,i)= readCipicHrtf(subject,  Ia_front_one(i), Ie_front_one(i),'l');
        single_two_hrir_l(:,i)= readCipicHrtf(subject,  Ia_front_two(i), Ie_front_two(i),'l');      
        %%计算两端点HRTF数据的权值
        single_factor_one(i) =abs( ( theta_front(i) - azimuth_cipic(Ia_front_one(i))) / ( azimuth_cipic(Ia_front_two(i)) - azimuth_cipic(Ia_front_one(i))) );
        single_factor_two(i) = abs( ( azimuth_cipic(Ia_front_two(i)) - theta_front(i)) / ( azimuth_cipic(Ia_front_two(i)) - azimuth_cipic(Ia_front_one(i))) ); 

        %%单线性未对齐——插值结果——左声道
        single_hrir_l_NC(:,i)= single_factor_two(i) * single_one_hrir_l(:,i) + single_factor_one(i) *single_two_hrir_l(:,i);%未对齐左声道单线性插值结果        
        %%单线性对齐——对齐结果——左声道    _C代表对齐之后的结果
        [max_single_one_hrir_l, index_single_one_hrir_l] = max( single_one_hrir_l(:,i));  
        [max_single_two_hrir_l, index_single_two_hrir_l] = max( single_two_hrir_l(:,i));
       
        single_two_hrir_l_C(:,i) = correlation_CorrectTime(index_single_one_hrir_l,single_one_hrir_l(:,i),index_single_two_hrir_l,single_two_hrir_l(:,i));
        [max_single_two_hrir_l_C, index_single_two_hrir_l_C] = max( single_two_hrir_l_C );%验证对齐与否          
        %%单线性对齐——插值结果——左声道
        single_hrir_l(:,i) = single_factor_two(i) * single_one_hrir_l(:,i) + single_factor_one(i) * single_two_hrir_l_C(:,i);
        [max_single_hrir_l, index_single_hrir_l] = max(single_hrir_l(:,i));
        
        if (azimuth_cipic(Ia_front_two(i)) - theta_front(i))> theta_front(i) - azimuth_cipic(Ia_front_one(i)) 
            single_hrir_l_C(:,i) = correlation_CorrectTime(index_single_one_hrir_l,single_one_hrir_l(:,i),index_single_hrir_l,single_hrir_l(:,i) );%对齐左声道单线性插值结果
            [max_single_hrir_l_C ,index_single_hrir_l_C] = max( single_hrir_l_C(:,i) );%验证对齐与否 
        else
            single_hrir_l_C(:,i) = correlation_CorrectTime(index_single_two_hrir_l,single_two_hrir_l(:,i),index_single_hrir_l,single_hrir_l(:,i) );%对齐左声道单线性插值结果
           [max_single_hrir_l_C, index_single_hrir_l_C] = max( single_hrir_l_C(:,i) );%验证对齐与否            
        end
        theta_start_index=i+1;
    end

  
%%后方插值结果
    theta_end_index=theta_start_index+length(theta_back)-1;
    for i=theta_start_index :theta_end_index    
        j=i-length(theta_front);        
        %%单线性——读取待插值点两端点的HRTF数据
        single_one_hrir_l(:,i)= readCipicHrtf(subject,  Ia_back_one(j), Ie_back_one(j),'l');
        single_two_hrir_l(:,i)= readCipicHrtf(subject,  Ia_back_two(j), Ie_back_two(j),'l');      
        %%计算两端点HRTF数据的权值
        single_factor_one(i) =abs( ( theta_back(j) - azimuth_cipic(Ia_back_one(j))) / ( azimuth_cipic(Ia_back_two(j)) - azimuth_cipic(Ia_back_one(j))) );
        single_factor_two(i) = abs( ( azimuth_cipic(Ia_back_two(j)) - theta_back(j)) / ( azimuth_cipic(Ia_back_two(j)) - azimuth_cipic(Ia_back_one(j))) ); 
        %%单线性未对齐——插值结果——左声道
        single_hrir_l_NC(:,i)= single_factor_two(i) * single_one_hrir_l(:,i) + single_factor_one(i) *single_two_hrir_l(:,i);%未对齐左声道单线性插值结果        
        %%单线性对齐——对齐结果——左声道    _C代表对齐之后的结果
        [max_single_one_hrir_l, index_single_one_hrir_l] = max( single_one_hrir_l(:,i));  
        [max_single_two_hrir_l, index_single_two_hrir_l] = max( single_two_hrir_l(:,i));
       
        single_two_hrir_l_C(:,i) = correlation_CorrectTime(index_single_one_hrir_l,single_one_hrir_l(:,i),index_single_two_hrir_l,single_two_hrir_l(:,i));
        [max_single_two_hrir_l_C, index_single_two_hrir_l_C] = max( single_two_hrir_l_C );%验证对齐与否          
        %%单线性对齐——插值结果——左声道
        single_hrir_l(:,i) = single_factor_two(i) * single_one_hrir_l(:,i) + single_factor_one(i) * single_two_hrir_l_C(:,i);
        [max_single_hrir_l, index_single_hrir_l] = max(single_hrir_l(:,i));
        
        if (azimuth_cipic(Ia_back_two(j)) - theta_back(j))> theta_back(j) - azimuth_cipic(Ia_back_one(j)) 
            single_hrir_l_C(:,i) = correlation_CorrectTime(index_single_one_hrir_l,single_one_hrir_l(:,i),index_single_hrir_l,single_hrir_l(:,i) );%对齐左声道单线性插值结果
            [max_single_hrir_l_C ,index_single_hrir_l_C] = max( single_hrir_l_C(:,i) );%验证对齐与否 
        else
            single_hrir_l_C(:,i) = correlation_CorrectTime(index_single_two_hrir_l,single_two_hrir_l(:,i),index_single_hrir_l,single_hrir_l(:,i) );%对齐左声道单线性插值结果
           [max_single_hrir_l_C, index_single_hrir_l_C] = max( single_hrir_l_C(:,i) );%验证对齐与否            
        end
        theta_start_index=i+1;
    end    

    
    %%左中方插值结果
    theta_end_index=theta_start_index+length(theta_left_center)-1;
    for i=theta_start_index :theta_end_index      
        j=i-length(theta_front)-length(theta_back);
        %%单线性——读取待插值点两端点的HRTF数据
        single_one_hrir_l(:,i)= readCipicHrtf(subject,  Ia_left_center_one(j), Ie_left_center_one(j),'l');
        single_two_hrir_l(:,i)= readCipicHrtf(subject,  Ia_left_center_two(j), Ie_left_center_two(j),'l');      
        %%计算两端点HRTF数据的权值  在-80点出的数据需要特殊处理
        if (theta_left_center(j) ==-80) 
              single_factor_one(i) =1;
              single_factor_two(i) =0; 
        else
              single_factor_one(i) =abs( ( theta_left_center(j) - azimuth_cipic(Ia_left_center_one(j))) /20 );
              single_factor_two(i) = abs( ( azimuth_cipic(Ia_left_center_two(j)) - theta_left_center(j)) /20 ); 
        end

        %%单线性未对齐——插值结果——左声道
        single_hrir_l_NC(:,i)= single_factor_two(i) * single_one_hrir_l(:,i) + single_factor_one(i) *single_two_hrir_l(:,i);%未对齐左声道单线性插值结果        
        %%单线性对齐——对齐结果——左声道    _C代表对齐之后的结果
        [max_single_one_hrir_l, index_single_one_hrir_l] = max( single_one_hrir_l(:,i));  
        [max_single_two_hrir_l, index_single_two_hrir_l] = max( single_two_hrir_l(:,i));
       
        single_two_hrir_l_C(:,i) = correlation_CorrectTime(index_single_one_hrir_l,single_one_hrir_l(:,i),index_single_two_hrir_l,single_two_hrir_l(:,i));
        [max_single_two_hrir_l_C, index_single_two_hrir_l_C] = max( single_two_hrir_l_C );%验证对齐与否          
        %%单线性对齐——插值结果——左声道
        single_hrir_l(:,i) = single_factor_two(i) * single_one_hrir_l(:,i) + single_factor_one(i) * single_two_hrir_l_C(:,i);
        [max_single_hrir_l, index_single_hrir_l] = max(single_hrir_l(:,i));
        
        if (azimuth_cipic(Ia_left_center_two(j)) - theta_left_center(j))> theta_left_center(j) - azimuth_cipic(Ia_left_center_one(j)) 
            single_hrir_l_C(:,i) = correlation_CorrectTime(index_single_one_hrir_l,single_one_hrir_l(:,i),index_single_hrir_l,single_hrir_l(:,i) );%对齐左声道单线性插值结果
            [max_single_hrir_l_C ,index_single_hrir_l_C] = max( single_hrir_l_C(:,i) );%验证对齐与否 
        else
            single_hrir_l_C(:,i) = correlation_CorrectTime(index_single_two_hrir_l,single_two_hrir_l(:,i),index_single_hrir_l,single_hrir_l(:,i) );%对齐左声道单线性插值结果
           [max_single_hrir_l_C, index_single_hrir_l_C] = max( single_hrir_l_C(:,i) );%验证对齐与否            
        end
        theta_start_index=i+1;
    end    
   
    
    %%右中方插值结果
    theta_end_index=theta_start_index+length(theta_right_center)-1;
    for i=theta_start_index :theta_end_index      
         j=i-length(theta_front)-length(theta_back)-length(theta_left_center);
        %%单线性——读取待插值点两端点的HRTF数据
        single_one_hrir_l(:,i)= readCipicHrtf(subject,  Ia_right_center_one(j), Ie_right_center_one(j),'l');
        single_two_hrir_l(:,i)= readCipicHrtf(subject,  Ia_right_center_two(j), Ie_right_center_two(j),'l');      
        %%计算两端点HRTF数据的权值
        if (theta_left_center(j) ==-80) 
              single_factor_one(i) =1;
              single_factor_two(i) =0; 
        else
              single_factor_one(i) =abs( ( theta_right_center(j) - azimuth_cipic(Ia_right_center_one(j))) /20 );
              single_factor_two(i) = abs( ( azimuth_cipic(Ia_right_center_two(j)) - theta_right_center(j)) /20 ); 
        end
        %%单线性未对齐——插值结果——左声道
        single_hrir_l_NC(:,i)= single_factor_two(i) * single_one_hrir_l(:,i) + single_factor_one(i) *single_two_hrir_l(:,i);%未对齐左声道单线性插值结果        
        %%单线性对齐——对齐结果——左声道    _C代表对齐之后的结果
        [max_single_one_hrir_l, index_single_one_hrir_l] = max( single_one_hrir_l(:,i));  
        [max_single_two_hrir_l, index_single_two_hrir_l] = max( single_two_hrir_l(:,i));
       
        single_two_hrir_l_C(:,i) = correlation_CorrectTime(index_single_one_hrir_l,single_one_hrir_l(:,i),index_single_two_hrir_l,single_two_hrir_l(:,i));
        [max_single_two_hrir_l_C, index_single_two_hrir_l_C] = max( single_two_hrir_l_C );%验证对齐与否          
        %%单线性对齐——插值结果——左声道
        single_hrir_l(:,i) = single_factor_two(i) * single_one_hrir_l(:,i) + single_factor_one(i) * single_two_hrir_l_C(:,i);
        [max_single_hrir_l, index_single_hrir_l] = max(single_hrir_l(:,i));
        
        if (azimuth_cipic(Ia_right_center_two(j)) - theta_right_center(j))> theta_right_center(j) - azimuth_cipic(Ia_right_center_one(j)) 
            single_hrir_l_C(:,i) = correlation_CorrectTime(index_single_one_hrir_l,single_one_hrir_l(:,i),index_single_hrir_l,single_hrir_l(:,i) );%对齐左声道单线性插值结果
            [max_single_hrir_l_C ,index_single_hrir_l_C] = max( single_hrir_l_C(:,i) );%验证对齐与否 
        else
            single_hrir_l_C(:,i) = correlation_CorrectTime(index_single_two_hrir_l,single_two_hrir_l(:,i),index_single_hrir_l,single_hrir_l(:,i) );%对齐左声道单线性插值结果
           [max_single_hrir_l_C, index_single_hrir_l_C] = max( single_hrir_l_C(:,i) );%验证对齐与否            
        end
        theta_start_index=i+1;
    end    


xls_file_name='.\水平方位(0~360度1度间隔)Hrtf_L插值结果.xls ';    
sheet_name = ['subject' , int2str(subject),'singleHrtf_L_C']; 
xlswrite(xls_file_name,single_hrir_l_C(:,1:160),sheet_name,'B3');%单线性对齐插值数据  前方
xlswrite(xls_file_name,single_hrir_l_C(:,161:320),sheet_name,'B205');%单线性对齐插值数据  后方
xlswrite(xls_file_name,single_hrir_l_C(:,321:340),sheet_name,'B407');%单线性对齐插值数据  左中
xlswrite(xls_file_name,single_hrir_l_C(:,341:360),sheet_name,'B609');%单线性对齐插值数据   右中

sheet_name = ['subject' , int2str(subject),'singleHrtf_L_NC']; 
xlswrite(xls_file_name,single_hrir_l_NC(:,1:160),sheet_name,'B3');%单线性对齐插值数据  前
xlswrite(xls_file_name,single_hrir_l_NC(:,161:320),sheet_name,'B205');%单线性对齐插值数据  后
xlswrite(xls_file_name,single_hrir_l_NC(:,321:340),sheet_name,'B407');%单线性对齐插值数据  左中
xlswrite(xls_file_name,single_hrir_l_NC(:,341:360),sheet_name,'B609');%单线性对齐插值数据  右中




