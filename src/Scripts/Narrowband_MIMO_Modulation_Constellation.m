%% MIMO Channel

RMS_DS=Statistics_MIMO.RMSDelaySpread;

% Coherence Bandwidth
Time_Duration=100*RMS_DS;
Index_Duration=ceil(Time_Duration/Param.System.TimeResolution);

%%  Message Definition

MessageLength=500;
SymbolDuration=Index_Duration;

% Modulation
Type='QAM';

%% Independent Channel Estimation

H_Narrow=zeros(Param.System.Nr,Param.System.Nt);

for i=1:Param.System.Nr
    for j=1:Param.System.Nt
        H_Narrow(i,j)=sum(MIMO_CIR.h{i,j});
    end
end

[ReceiveMatrix,Gain,TransmitMatrix]=svd(H_Narrow);
GainVector=Gain(logical(eye(size(Gain))));

