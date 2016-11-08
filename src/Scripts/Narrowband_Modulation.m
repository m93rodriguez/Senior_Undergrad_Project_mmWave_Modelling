%% MIMO Channel

RMS_DS=Statistics_MIMO.RMSDelaySpread;

% Coherence Bandwidth
Time_Duration=100*RMS_DS;
Index_Duration=ceil(Time_Duration/Param.System.TimeResolution);

%%  Message Definition

Modulation_Definition

%% Independent Channel Estimation

H_Narrow=zeros(Param.System.Nr,Param.System.Nt);

for i=1:Param.System.Nr
    for j=1:Param.System.Nt
        H_Narrow(i,j)=sum(MIMO_CIR.h{i,j});
    end
end

[ReceiveMatrix,Gain,TransmitMatrix]=svd(H_Narrow);
GainVector=Gain(logical(eye(size(Gain))));

%% Modulation

x=Symbol_Modulation(Stream,ModulationDefinition);
s=TransmitMatrix*x;
% Normalize transmit power
s=s/sqrt(Param.System.Nt);

%% Received signal

% Function for measuring antenna power
AntennaPower=@(v) diag(v*v'/length(v));

r=Matrix_Convolution_Fast(s,MIMO_CIR);
% r=H_Narrow*s;

%% Determine Noise Power

SNR=inf;
ReceivedSignalPower=sum(AntennaPower(r))*ModulationDefinition.SymbolDuration;

% Noise
NoisePowerDensity=ReceivedSignalPower/SNR/Param.System.Nr;

Noise=normrnd(0,sqrt(NoisePowerDensity),size(r))+1i*normrnd(0,sqrt(NoisePowerDensity),size(r));
% Noise=Noise/sqrt(2);

Noisy_Signal=r+Noise;

%% Demodulation
y=ReceiveMatrix'*Noisy_Signal;
y=y*sqrt(Param.System.Nt);
Demodulation=Symbol_Demodulation(y,Gain,ModulationDefinition);

%% Error Statistics
ErrorStatistics=Extract_Error_Statistics(Stream,ModulationDefinition,Demodulation);
%% Plotting
Antenna=4;

InSymbols=ErrorStatistics.InSymbols(Antenna,:);
OutSymbols=Demodulation.SymbolPosition{Antenna};
OutSymbols=OutSymbols(1:length(InSymbols));

figure
scatter(real(OutSymbols),imag(OutSymbols),10,InSymbols,'filled');
colormap winter

%% Interference Noise
GrayMap=ModulationDefinition.GrayCodeMapping{Antenna};
Map=ModulationDefinition.ConstellationMap{Antenna};
SymbolMeans=Map(GrayMap(InSymbols));


InterferenceNoise=(OutSymbols-SymbolMeans);
figure,scatter(real(InterferenceNoise),imag(InterferenceNoise),10,'filled');

[CDF,Value]=histcounts(real(InterferenceNoise),200,'Normalization','cdf');
Value=(Value(1:end-1)+Value(2:end))/2;
x_CDF=linspace(min(Value),max(Value),length(CDF));
y_CDF=normcdf(x_CDF,mean(real(InterferenceNoise)),std(real(InterferenceNoise)));
figure,plot(Value,CDF,'-*'),hold on, plot(x_CDF,y_CDF,'-r*')




