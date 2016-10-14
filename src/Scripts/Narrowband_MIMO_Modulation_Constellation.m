%% MIMO Channel

RMS_DS=Statistics_MIMO.RMSDelaySpread;

% Coherence Bandwidth
Time_Duration=500*RMS_DS;
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

%% Received signal

r=Matrix_Convolution_Fast(s,MIMO_CIR);
% r=H_Narrow*s;

% Noise
NoisePower=2;

Noise=normrnd(0,sqrt(NoisePower),size(r))+1i*normrnd(0,sqrt(NoisePower),size(r));
Noise=Noise/sqrt(2);

Noisy_Signal=r+Noise;

%% Demodulation
y=ReceiveMatrix'*Noisy_Signal;
Demodulation=Symbol_Demodulation(y,Gain,ModulationDefinition);
OutputStream=Demodulation.Stream(1:StreamLength);

%% Plotting
Antenna=1;
InSymbols=Bit_Multiplexing(Stream,ModulationDefinition);
InSymbols=InSymbols(Antenna,:);
OutSymbols=Demodulation.Symbols{Antenna};
OutSymbols=OutSymbols(1:length(InSymbols));

figure
scatter(real(OutSymbols),imag(OutSymbols),10,InSymbols,'filled');
colormap winter

%% Interference Noise
GrayMap=ModulationDefinition.GrayCodeMapping{Antenna};
Map=ModulationDefinition.ConstellationMap{Antenna};
SymbolMeans=Map(GrayMap(InSymbols));

InterferenceNoise=real(OutSymbols-SymbolMeans);
% scatter(real(InterferenceNoise),imag(InterferenceNoise),10,'filled');

[CDF,Value]=histcounts(InterferenceNoise,10,'Normalization','cdf');
Value=(Value(1:end-1)+Value(2:end))/2;
x=linspace(min(Value),max(Value),length(CDF));
y=normcdf(x,mean(InterferenceNoise),std(InterferenceNoise));
figure
plot(Value,CDF,'-*'),hold on, plot(x,y,'-*r')




