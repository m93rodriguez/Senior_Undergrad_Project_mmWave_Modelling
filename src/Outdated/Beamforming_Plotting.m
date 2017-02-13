Beamforming_Process2

%% ------------------------------------------------------------------------
% Functions
GetPower=@(x) sum(x(:));
U=@(x,x0,N) psinc(pi*(sin(x)-sin(x0)),N).^2/N;
% get PDP

AngPDP=MIMO_CIR.PDP;
AngPDP=cellfun(GetPower,AngPDP);
TotalPower=sum(AngPDP);

Time=MIMO_CIR.Time;
RMS=Statistics_MIMO.RMSDelaySpread;

AOD=MIMO_CIR.AOD;
AOA=MIMO_CIR.AOA;
% Angular discretization
Theta=linspace(-pi,pi,1000);

% ------------------------------------------------------------------------
%%
figure(2)
clf
polar(AOD,AngPDP/max(AngPDP),'*k')


%%
lambda=Param.Phys.lambda;
Separation=Param.System.AntennaSeparation;

Distance=100*lambda;

[x_Far,y_Far]=pol2cart(Theta,Distance);

y_pos=1:AntennasPerCluster;
y_pos=Param.System.AntennaSeparation*(y_pos-mean(y_pos));
x_pos=zeros(size(y_pos));

hold on
for cont=1:NumClusters
    Shift=(0:AntennasPerCluster-1)'*pi*sin(ClusterAngle.AOD(cont));
    
    Gain=zeros(size(Theta));
    for pos=1:length(Theta)
        for antenna=1:AntennasPerCluster
            
            d=sqrt((y_Far(pos)-y_pos(antenna))^2+(x_Far(pos)-x_pos(antenna))^2);
            Gain(pos)=Gain(pos)+exp(1i*(2*pi*d/lambda+Shift(antenna)))/(AntennasPerCluster);
        end
    end
    
    
    polar(Theta,abs(Gain))
end

figure(1)
clf
for cont=1:4
    subplot(4,1,cont)
    stem(abs(Beam_MIMO.h{cont}))
end

