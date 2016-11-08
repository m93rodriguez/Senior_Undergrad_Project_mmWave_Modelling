%% MIMO Channel

RMS_DS=Statistics_MIMO.RMSDelaySpread;

% Coherence Bandwidth
Time_Duration=100*RMS_DS;
Index_Duration=ceil(Time_Duration/Param.System.TimeResolution);

%%  Limit Number of Antennas

Nmax=3;


MIMO_CIR_Limited=struct;
MIMO_CIR_Limited.ReceiveAntennas=Nmax;
MIMO_CIR_Limited.TransmitAntennas=Nmax;
MIMO_CIR_Limited.Index=MIMO_CIR.Index;
MIMO_CIR_Limited.Time=MIMO_CIR.Time;
MIMO_CIR_Limited.AOA=MIMO_CIR.AOA;
MIMO_CIR_Limited.AOD=MIMO_CIR.AOD;
MIMO_CIR_Limited.h=MIMO_CIR.h(1:Nmax,1:Nmax);

for cont=1:numel(MIMO_CIR_Limited.Index)
    MIMO_CIR_Limited.H{cont}=MIMO_CIR.H{cont}(1:Nmax,1:Nmax);
    MIMO_CIR_Limited.PDP{cont}=MIMO_CIR.PDP{cont}(1:Nmax,1:Nmax);
end

