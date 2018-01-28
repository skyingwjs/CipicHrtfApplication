%% matlab 画出CIPIC库的高度角 分布图
clc;
clear all;

r=10;%半径
seta=0:0.001:2*pi;
xx=r*cos(seta);
yy=r*sin(seta);
plot(xx,yy);%画圆
axis([-12 12 -12 12]) ;
hold on;

elevation_cipic = -45:360/64:235;
elevation=zeros(1,length(elevation_cipic));
elevation=elevation_cipic;%不需要坐标转换

elevation_xx=zeros(1,length(elevation_cipic));
elevation_yy=zeros(1,length(elevation_cipic));
for  i=1:length(elevation)
    elevation_xx(i)=r*cos(elevation(i)*pi/180);
    elevation_yy(i)=r*sin(elevation(i)*pi/180);
end

plot([-12 12],[0 0],'g-');
hold on;
plot([0 0],[-12 12],'g-');
hold on;

%前方方位角分布
for i=1:length(elevation)
  plot([0,elevation_xx(i)],[0,elevation_yy(i)],'r-');
  hold on;
end
