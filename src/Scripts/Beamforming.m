%% Analyze Angular Spectrum

main
%% Get the angular link power

PowerProfile=MIMO_CIR.PDP;
Time=MIMO_CIR.Time;

GetPower=@(x) sum(x(:));

AngularSpectrum=cellfun(GetPower,PowerProfile);
[~,I]=max(AngularSpectrum);
AOD=MIMO_CIR.AOD;
AOD_Max=AOD(I);
AOA=MIMO_CIR.AOA;
AOA_Max=AOA(I);
theta=linspace(0,2*pi,500);

clf

subplot(2,2,1)
Plot_polar_dB(AOD,AngularSpectrum/max(AngularSpectrum),30,'*')
T1=title('Angle of Departure');
T1.Position=[0 1.2 0];
hold on
Theo=psinc((sin(theta)-sin(AOD_Max))*pi,8);
polar(theta,abs(Theo)/8);


subplot(2,2,2)
Plot_polar_dB(AOA,AngularSpectrum/max(AngularSpectrum),30,'*')
T2=title('Angle of Arrival');
T2.Position=[0,1.2,0];
hold on
Theo=psinc((sin(theta)-sin(AOA_Max))*pi,8);
polar(theta,abs(Theo)/8);

%% Get Number of Lobes

Rect=@(x,RMS) double((abs(wrapToPi(x))<RMS/2));

% for AOD
RMS=deg2rad(Param.Spatial.AS_AOD_az);

Ang=linspace(0,2*pi,1000);

for cont=1:length(Ang)
    Lobe_AOD(cont)=sum(Rect(AOD-Ang(cont),RMS).*AngularSpectrum);
    Lobe_AOA(cont)=sum(Rect(AOA-Ang(cont),RMS).*AngularSpectrum);
end

LengthFilter=RMS/mean(diff(Ang));
% LengthFilter=50;
% FilteredLobe_AOD=conv(Lobe_AOD,ones(1,round(LengthFilter)),'same');
FilteredLobe_AOD=cconv(Lobe_AOD,ones(1,round(LengthFilter)),1000);
% FilteredLobe_AOA=conv(Lobe_AOA,ones(1,round(LengthFilter)),'same');
FilteredLobe_AOA=cconv(Lobe_AOA,ones(1,round(LengthFilter)),1000);
subplot(2,2,3)
% polar(Ang,FilteredLobe_AOD/LengthFilter)
Plot_polar_dB(Ang,FilteredLobe_AOD/max(FilteredLobe_AOD),10)
subplot(2,2,4)
% polar(Ang,FilteredLobe_AOA/LengthFilter)
Plot_polar_dB(Ang,FilteredLobe_AOA/max(FilteredLobe_AOA),10)

%% Using Directivity

NumberAntennas=16;
U=@(x,x0,N) abs(psinc(pi*(sin(x)-sin(x0)),N)/sqrt(N)).^2 ;
Ang=linspace(-pi/2,pi/2,1000);

for cont=1:length(Ang)
    
    Power=U(AOD,Ang(cont),NumberAntennas).*AngularSpectrum;
    Lobe_AOD(cont)=sum(Power);
    
    
    MeanTime=sum(Power.*Time)/sum(Power);
    DelaySpread(cont)=sqrt(sum((Time-MeanTime).^2.*Power/sum(Power)));
end

clf

Lobe_AOD=Lobe_AOD/max(Lobe_AOD);
DelaySpread=DelaySpread/(max(DelaySpread));
Ratio=Lobe_AOD.^1.5./DelaySpread;
Ratio=Ratio/max(Ratio);
polar(Ang,Lobe_AOD)
hold on
polar(Ang,DelaySpread)
L=polar(Ang,Ratio,'k');
L.LineWidth=2;
polar(AOD,AngularSpectrum/max(AngularSpectrum),'*k')

% Detect local maxima

x=diff(Ratio);
y=diff(x);
x0=x(2:end).*x(1:end-1);
x0=x0<=0;
y0=y<0;
z=logical(x0.*y0);
Ind=find(z);
Ind=Ind(Ratio(z)>0.1)+1;
if(Ratio(1)>0.1)&&(y(1)<0); Ind=[1 Ind]; end
if(Ratio(end)>0.1)&&(y(end)<0); Ind=[Ind length(Ratio)]; end
    

figure
plot(Ang,Ratio);
hold on
plot(Ang(Ind),Ratio(Ind),'k*');

%% Check Shared area

N=length(Ind);
Ang=linspace(-pi/2,pi/2,1000);
Angles=Ang(Ind);

PerGroup=floor(16/N);

Group=PerGroup*ones(1,N);

for i=1:16-N*PerGroup
    Group(i)=Group(i)+1;
end

for i=1:N
    Vec1=U(AOD,Angles(i),Group(i)).*AngularSpectrum/Group(i);
    for j=1:N
        Vec2=U(AOD,Angles(j),Group(j)).*AngularSpectrum/Group(j);
        
        Shared(i,j)=1-sum(abs(Vec1-Vec2))/(sum(Vec1+Vec2));
    end
end

figure
Ang=linspace(0,2*pi,1000);


for i=1:N
    polar(Ang,U(Ang,Angles(i),Group(i))/Group(i))
    hold on
end
polar(AOD,AngularSpectrum/max(AngularSpectrum),'*k')


