%% 
function hrtf_C1 = correlation_CorrectTime(index1,hrtf1,index2_o,hrtf2)
number = 200;  %%%序列采样点的个数
for i = 1:21
    index2 = index2_o + i-11;
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
    rescult = corrcoef(hrtf1,hrtf_C);
    correlation(i) = rescult(1,2);
end
[~, index] = max(correlation);
index2 = index2_o + index-11;
hrtf_C1 = correctTime(index1,index2,hrtf2);
