%% Obtain System Properties
main

lambda=Param.Phys.lambda;
Separation=Param.System.AntennaSeparation;
N=Param.System.Nt;
N=10;

%% Geometry Definition
Distance=100*lambda;
theta=linspace(0,2*pi,300000);

[x_Far,y_Far]=pol2cart(theta,Distance);

%% Antenna array definition

y_pos=1:N;
y_pos=Param.System.AntennaSeparation*(y_pos-mean(y_pos));
x_pos=zeros(size(y_pos));

%% Phase shifts
clf
for Direction=0:1:360

Direction=deg2rad(Direction);

n=0:N-1;
Shift=-2*pi/lambda*n*Separation*sin(Direction);
Shift=Shift+0*randi(4,size(Shift));

%% Calculate phase shifts

Gain=zeros(size(theta));
for pos=1:length(theta)
    for antenna=1:N
        
        d=sqrt((y_Far(pos)-y_pos(antenna))^2+(x_Far(pos)-x_pos(antenna))^2);
        Gain(pos)=Gain(pos)+exp(1i*(2*pi*d/lambda+Shift(antenna)))/sqrt(N);
    end
end

%% Plotting

% close all

% figure
% plot(x,y)
% hold on
% scatter(x_pos,y_pos,'filled')

% figure
% hold off
% % polar(SpatialLobes.AOD,ones(size(SpatialLobes.AOD)),'*')
% hold on
clf
Plot_polar_dB(theta,abs(Gain/sqrt(N)).^2,5,'b')
% hold on
% polar(theta,0.5*ones(size(theta)),'r')
% Theoretical=1*psinc((sin(theta)-sin(Direction))*2*pi*Separation/lambda,N)/N;
% polar(theta,abs(Theoretical),'k')
% hold off
pause(0.001)
mean(abs(Gain).^2)
end








