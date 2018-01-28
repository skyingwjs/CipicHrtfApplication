%% matlab 画出CIPIC库的方位角 分布图
clc;
clear all;

r=10;%半径
seta=0:0.001:2*pi;
xx=r*cos(seta);
yy=r*sin(seta);
plot(xx,yy);%画圆
axis([-12 12 -12 12]) ;
hold on;

azimuth_cipic = [-80 -65 -55 -45:5:45 55 65 80];
azimuth=zeros(1,length(azimuth_cipic));
%坐标系转换
for i=1:length(azimuth_cipic)
    if azimuth_cipic(i)>=0
        azimuth(i)=90-azimuth_cipic(i);%角度
    else
        azimuth(i)=90+abs(azimuth_cipic(i));        
    end
end

azimuth_xx=zeros(1,length(azimuth_cipic));
azimuth_yy=zeros(1,length(azimuth_cipic));
for  i=1:length(azimuth)
    azimuth_xx(i)=r*cos(azimuth(i)*pi/180);
    azimuth_yy(i)=r*sin(azimuth(i)*pi/180);
end

plot([-12 12],[0 0],'g-');
hold on;
plot([0 0],[-12 12],'g-');
hold on;

%前方方位角分布
for i=1:length(azimuth)
  plot([0,azimuth_xx(i)],[0,azimuth_yy(i)],'r-');
  hold on;
end

%后方方位角分布
for i=1:length(azimuth)
  plot([0,azimuth_xx(i)],[0,-azimuth_yy(i)],'r-');
  hold on;
end