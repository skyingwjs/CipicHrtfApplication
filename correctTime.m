%% Peking库1024  Cipic库200
function hrtf_C = correctTime(index1,index2,hrtf2)
number = 200;%%%序列采样点的个数
if(index2>index1)
    for j=1:number
        if(j<number+index1-index2+1)
            hrtf_C(j) = hrtf2(j+index2-index1);
        else
            hrtf_C(j) = 0;
        end
    end
else
    for j=1:number
        if(j>index1-index2)
            hrtf_C(j) = hrtf2(j+index2-index1);
        else
            hrtf_C(j) = 0;
        end
    end
end