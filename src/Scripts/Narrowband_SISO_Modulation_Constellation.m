%% SISO Channel
h=SISO_CIR.h;

RMS_DS=Statistics_SISO.RMSDelaySpread;

% Coherence Bandwidth
Time_Duration=100*RMS_DS;
Index_Duration=ceil(Time_Duration/Param.System.TimeResolution);

% Phase Loop

Phase_Shift=sum(h);
Phase_Shift=angle(Phase_Shift);
h=h*exp(-1i*Phase_Shift);

%% Message Definition

MessageLength=500;
SymbolDuration=Index_Duration;

% Modulation

Type='PSK';
BitsPerSymbol=4;
NumSymbols=2^BitsPerSymbol;
Map=Generate_Constellation_Map(BitsPerSymbol,Type);

SentSymbols=randi(NumSymbols,1,MessageLength);

x=[];
for cont=1:MessageLength
    x=[x ones(1,SymbolDuration)*Map(SentSymbols(cont))];
end

% Normalize Energy
EnergyPerSymbol=x*x'/length(x);
x=x/sqrt(EnergyPerSymbol);

%% Received Signal

% Channel effect
r=conv(x,h);

% AWGN
NoisePower=0;
Noise=normrnd(0,sqrt(NoisePower),size(r))+...
    1i*normrnd(0,sqrt(NoisePower),size(r));
Noise=Noise/sqrt(2);

% Noisy signal
r=r+Noise;

% Amplificationh
r=r/abs(sum(h))*sqrt(EnergyPerSymbol);

%% Demodulation

MatchedFilter=ones(1,SymbolDuration)/SymbolDuration;

y=conv(r,MatchedFilter);
Sampling=1:SymbolDuration:length(y);
DetectedSymbol=y(Sampling);
DetectedSymbol=DetectedSymbol(2:end-1);

InPhase=real(DetectedSymbol);
Quadrature=imag(DetectedSymbol);

% figure
scatter(InPhase,Quadrature,30,SentSymbols,'filled')
colormap jet

OutputSymbols=Demodulate_Constellation(Map,DetectedSymbol);
BER=abs(OutputSymbols-SentSymbols);
BER=sum(BER>0)/length(BER)
