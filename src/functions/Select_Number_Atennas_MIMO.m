function MIMO_CIR_Limited=Select_Number_Atennas_MIMO(MIMO_CIR,N)

MIMO_CIR_Limited=struct;
MIMO_CIR_Limited.ReceiveAntennas=N;
MIMO_CIR_Limited.TransmitAntennas=N;
MIMO_CIR_Limited.Index=MIMO_CIR.Index;
MIMO_CIR_Limited.Time=MIMO_CIR.Time;
MIMO_CIR_Limited.AOA=MIMO_CIR.AOA;
MIMO_CIR_Limited.AOD=MIMO_CIR.AOD;
MIMO_CIR_Limited.h=MIMO_CIR.h(1:N,1:N);

for cont=1:numel(MIMO_CIR_Limited.Index)
    MIMO_CIR_Limited.H{cont}=MIMO_CIR.H{cont}(1:N,1:N);
    MIMO_CIR_Limited.PDP{cont}=MIMO_CIR.PDP{cont}(1:N,1:N);
end

end