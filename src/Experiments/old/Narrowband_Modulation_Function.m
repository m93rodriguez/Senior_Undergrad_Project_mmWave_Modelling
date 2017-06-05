function [Output,ModulationDefinition]=...
    Narrowband_Modulation_Function(MIMO_CIR,Statistics_MIMO,...
    ModulationDefinition,Param,Stream)
%% MIMO Channel

RMS_DS=Statistics_MIMO.RMSDelaySpread;

% Coherence Bandwidth
Time_Duration=ModulationDefinition.TimeRatio*RMS_DS;
Index_Duration=ceil(Time_Duration/Param.System.TimeResolution);

ModulationDefinition.SymbolDuration=Index_Duration;
ModulationDefinition.PulseShape=ones(1,ModulationDefinition.SymbolDuration);
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

r=Matrix_Convolution_Fast(s,MIMO_CIR);
%% Output
Output=struct;
Output.ReceiveMatrix=ReceiveMatrix;
Output.Gain=Gain;
Output.ReceivedSignal=r;
end