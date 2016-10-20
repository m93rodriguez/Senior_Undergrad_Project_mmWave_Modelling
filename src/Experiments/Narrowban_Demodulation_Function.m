function ErrorStatistics=Narrowban_Demodulation_Function(SNR,ModulationDefinition,Stream,Param,Input)

r=Input.ReceivedSignal;
Gain=Input.Gain;
ReceiveMatrix=Input.ReceiveMatrix;

%% Determine Noise Power

NoisePowerDensity=Gain.^2*ModulationDefinition.SymbolDuration/SNR;
Noise=normrnd(0,sqrt(NoisePowerDensity),size(r))+1i*normrnd(0,sqrt(NoisePowerDensity),size(r));

Noisy_Signal=r+Noise;

%% Demodulation
y=ReceiveMatrix'*Noisy_Signal;
y=y*sqrt(Param.System.Nt);
Demodulation=Symbol_Demodulation(y,Gain,ModulationDefinition);

%% Error Statistics
ErrorStatistics=Extract_Error_Statistics(Stream,ModulationDefinition,Demodulation);
end