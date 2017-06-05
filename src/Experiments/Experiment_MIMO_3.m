%% Experiment MIMO 3 - Beamforming

% This experiment is a collection of past experiments, as the efficiency of
% the challenge and the characteristics of Interference Noise are of
% interest, but also including new variables and techniques such as
% Beamforming clustering. Modifications were made to input parameter
% definitions, to be able to make realistics comparisons between variables
% and iterations.

% Input Variables:
% - Modulation Order
% - Bandwidth
% - Signal to Noise Ratio
% - Number of Beamforming Clusters

% Output Variables:
% - Error statistics: this will be measured for the overall collection and
%   for each stream of data, and will include bit and symbol error.
% - RMS Delay Spread for each channel response
% - Channel gain for each data stream in the Narrowband approximation
% - Interference noise Amplitude

%% Set Up System

Input_Parameters
addpath functions
addpath Scripts
addpath Experiments

%% Parameters

NumberOfCIRs=50;

ModulationOrder=[1,2,4,6,8];

SymbolDuration=[20 27 40 60 100 160 200];
% Corresponding to:
SymbolDuration_ns=[50 67.5 100 150 250 400 500];
SymbolDuration_MHz=[20 15 10 6.7 4 2.5 2];

SNR_Range=[Inf 5 7 10 20 50 70 100];

NumClusters=[16 8 4 2 1];

ModulationType='QAM';
GrayCode='on';
%% Output Variables

GainVector=cell(numel(NumClusters),1);
SpatialStatistics=zeros(NumberOfCIRs,numel(NumClusters));
TimeStatistics=cell(NumberOfCIRs,numel(NumClusters));
ErrorStatistics=cell(NumberOfCIRs,numel(NumClusters),numel(ModulationOrder));
%     ,numel(SymbolDuration));


%% Cycles
disp('Starting Iterations')
for cont_CIR=1:NumberOfCIRs  
    CIR=System_Generation(Param);
    MIMO_CIR=CIR.MIMO;
    
    for cont_Clusters=1:numel(NumClusters)
        
        BF_Clusters=Beamforming_Clusters(MIMO_CIR,NumClusters(cont_Clusters));
        Beam_MIMO=Beamforming_MIMO_CIR(BF_Clusters,MIMO_CIR);
        StreamLength=NumClusters(cont_Clusters)*5000;
        
        %------------
        TempGain=svd(Beam_MIMO.Narrowband);
        GainVector{cont_Clusters}(:,cont_CIR)=TempGain;
        SpatialStatistics(cont_CIR,cont_Clusters)=BF_Clusters.PhysicalClusters;
        TimeStatistics{cont_CIR,cont_Clusters}=Extract_MIMO_Statistics(Beam_MIMO);
        %------------
        for cont_Order=1:numel(ModulationOrder)
            
            BitsPerSymbol=ModulationOrder(cont_Order)*ones(1,Beam_MIMO.TransmitAntennas);
            AuxTime=cell(1,numel(SymbolDuration));
            parfor cont_Time=1:numel(SymbolDuration)
                
                PowerGain=mean(TempGain.^2);
                ExpectedReceivedPower=SymbolDuration(cont_Time)*PowerGain;
                NoisePowerDensity=ExpectedReceivedPower./SNR_Range;
                
                % Note: The SNR here is for the overall system. As the total power is the
                % sum of the powers in each receive antenna, the noise power density is
                % divided by the number of receive antennas inside the communication
                % function, for SNR normalization.
                
               %ErrorStatistics{cont_CIR,cont_Clusters,cont_Order,cont_Time}...
                   AuxTime{cont_Time}=Simulate_Channel(Beam_MIMO,StreamLength,...
                   SymbolDuration(cont_Time),BitsPerSymbol,NoisePowerDensity,'QAM');
                
            end % Time Duration
            ErrorStatistics{cont_CIR,cont_Clusters,cont_Order}=AuxTime;
        end % Modulation Order
    end % Number of Clusters BF
    
    disp(['Repetition: ', num2str(cont_CIR)])
    
end % enc CIR