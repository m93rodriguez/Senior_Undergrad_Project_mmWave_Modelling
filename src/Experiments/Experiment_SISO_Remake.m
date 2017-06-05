%% Experiment SISO - Remake
% This experiment will measure the performance of a SISO channel with the
% paremters defined for Experiment MIMO 3 for being able to make a thorough
% comparison of the results of both experiments.

% Input Variables
%   - Modulation Type
%   - Modulation Order
%   - Signal to Noise Ratio
%   - Bandwidth

% Output Variables
%   - Error Statistics
%   - RMS Delay Spread
%   - Channel Gain

%% Set Up System

Input_Parameters
Param.System.Nt=1;
Param.System.Nr=1;
addpath functions
addpath Scripts
addpath Experiments

%% Parameters

NumberOfCIRs=100;

ModulationType={'PSK','QAM'};
ModulationOrder=[1,2,4,6,8];

SymbolDuration=[20 27 40 60 100 160 200];
% Corresponding to:
SymbolDuration_ns=[50 67.5 100 150 250 400 500];
SymbolDuration_MHz=[20 15 10 6.7 4 2.5 2];

SNR_Range=[Inf 5 7 10 20 50 70 100];

GrayCode='on';

StreamLength=5000;

%% Output Variables

GainVector=zeros(1,NumberOfCIRs);
TimeStatistics=cell(NumberOfCIRs);
ErrorStatistics=cell(NumberOfCIRs,length(ModulationType),numel(ModulationOrder));

%% Cycles

disp('Starting Iterations')
for cont_CIR=1:NumberOfCIRs
    
    CIR=System_Generation(Param);
    MIMO_CIR=CIR.MIMO;
    Gain=svd(MIMO_CIR.Narrowband);
    
    GainVector(cont_CIR)=Gain;
    TimeStatistics{cont_CIR}=Extract_MIMO_Statistics(MIMO_CIR);
    
    for cont_Type=1:length(ModulationType)
        
        for cont_Order=1:length(ModulationOrder)
            BitsPerSymbol=ModulationOrder(cont_Order);
            AuxTime=cell(1,length(SymbolDuration));
            
            parfor cont_Time=1:length(SymbolDuration)
                
                PowerGain=mean(Gain.^2);
                ExpectedReceivedPower=SymbolDuration(cont_Time)*PowerGain;
                NoisePowerDensity=ExpectedReceivedPower./SNR_Range;
                
                AuxTime{cont_Time}=Simulate_Channel(MIMO_CIR,StreamLength,...
                    SymbolDuration(cont_Time),BitsPerSymbol,NoisePowerDensity,...
                    ModulationType{cont_Type});
                
            end % End Time
            ErrorStatistics{cont_CIR,cont_Type,cont_Order}=AuxTime;
        end % End Mod Order
    end % End Mod type
    disp(['Repetition: ',num2str(cont_CIR)])
end % End CIR


