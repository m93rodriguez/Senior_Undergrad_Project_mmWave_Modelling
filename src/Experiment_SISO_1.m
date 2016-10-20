%% Grand Statistics Test 1


% This test has the objective of measuring the results of tests realized by
% generating a number of channel impulse response to measure:
%   - Time Statistics (RMS Delay Spread)
%   - Bit and Symbol Error
%   - Modulation Order
%   - Signal to Noise Ratio
%   - Data Rate
%   - Bandwidth

% Inputs:
%   - Modulation Type
%   - Modulation order (bits per symbol)
%   - Signal to Noise Ratio
%   - Symbol Duration vs Channel Delay Spread

% Outputs:
%   - RMS Delay Spread
%   - Bit Error
%   - Symbol Error
%   - Data Rate
%   - Bandwidth
%   - Channel Gain


%% Test Parameters

NumberOfCIRs=100;

NarrowbandFactor=10:10:100;
ModulationType={'QAM','PSK'};
ModulationOrder={2:8,1:7};
SNR_Range=linspace(0.1,5,10); % min 0.1, max 5, Num points 10



%%

Input_Parameters
addpath functions
addpath Scripts
addpath Experiments

Resultados=struct;


for cont=1:NumberOfCIRs
    
    CIR=System_Generation(Param);
    MIMO_CIR=CIR.MIMO;
    Statistics_MIMO=Extract_MIMO_Statistics(MIMO_CIR);
    
    Resultados.TimeStatistics{cont}=Statistics_MIMO;
    
    for Type=1:2
        
        ModulationDefinition.Type=ModulationType{Type};
        cont_Time=1;
        for TimeRatio=NarrowbandFactor
            ModulationDefinition.TimeRatio=TimeRatio;
            cont_Order=1;
            for Order=ModulationOrder{Type}
                
                ModulationDefinition.BitsPerSymbol=Order;
                Modulation_Experiment
                [Output,ModulationDefinition]=...
                    Narrowband_Modulation_Function(MIMO_CIR,Statistics_MIMO,...
                    ModulationDefinition,Param,Stream);
                
                cont_SNR=1;
                for SNR=SNR_Range;
                    ErrorStatistics=Narrowban_Demodulation_Function(SNR,...
                        ModulationDefinition,Stream,Param,Output);
                    
                    Resultados.Error{cont,Type,cont_Time,cont_Order,cont_SNR}=...
                        ErrorStatistics;
                    cont_SNR=cont_SNR+1;
                end
                cont_Order=cont_Order+1;
            end
            
            cont_Time=cont_Time+1;
        end
        
        
    end
    Resultados.Gain=Output.Gain;
    Done=round(cont/NumberOfCIRs*100);
    fprintf(['Completition: ',num2str(Done),'%% \n'])
end

