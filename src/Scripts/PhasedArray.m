% clear all

lambda=Param.Phys.lambda;
%% Geometry Definition
Distance=100*lambda;
theta=linspace(0,2*pi,3000);

[x_Far,y_Far]=pol2cart(theta,Distance);

%% Antenna array definition

N=Param.System.Nt;
N=10;



y_pos=1:N;
y_pos=Param.System.AntennaSeparation*(y_pos-mean(y_pos));
x_pos=zeros(size(y_pos));


Phase=2*pi*rand(1,N);
Phase=zeros(1,N);
% Phase=(1:N)/2/pi;
% Phase=angle(TransmitMatrix*x);



%% Calculate phase shifts
Gain=zeros(size(theta));
for pos=1:length(theta)
    for antenna=1:N
        
        d=sqrt((y_Far(pos)-y_pos(antenna))^2+(x_Far(pos)-x_pos(antenna))^2);
        Gain(pos)=Gain(pos)+exp(1i*(2*pi*d/lambda+Phase(antenna)));
    end
end
Gain=Gain/N;
%% Plotting

% close all

% figure
% plot(x,y)
% hold on
% scatter(x_pos,y_pos,'filled')

% figure
hold off
polar(SpatialLobes.AOD,ones(size(SpatialLobes.AOD)),'*')
hold on
polar(theta,0.5*ones(size(theta)),'r')
polar(theta,abs(Gain),'b')
hold off








