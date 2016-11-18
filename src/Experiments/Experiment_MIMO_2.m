%% Experiment MIMO - 1.2

% Determine the effects of the Interference Noise
% Input Variables:
% - Number of Antennas
% - Narrowband Factor
% - Antenna Spacing
% - Delay Spread
% - Modulation Order

% Output Variable
% - Noise Amplitud
% - Gaussianity (h, and p-value)

%% Parameters

NumberOfCIRS=30;
NarrowbandFactor=10:20:100;
MaxAntennas=16;
Separation=1:2:10;
ModulationOrder=[2,3];

%% Set up System

Input_Parameters
addpath functions
addpath Scripts
addpath Experiments

% Resultados_MIMO_1=struct;

Param.System.Nt=MaxAntennas;
Param.System.Nr=MaxAntennas;

cont_Completition=0;

Resultados_MIMO_2=cell(numel(Separation),NumberOfCIRS,numel(1:2:MaxAntennas),numel(ModulationOrder));

for cont_Separation=1:numel(Separation)
    Param.System.AntennaSeparation=Param.Phys.lambda*Separation(cont_Separation)/2;
    for cont_CIR=1:NumberOfCIRS
        CIR=System_Generation(Param);
        MIMO_CIR=CIR.MIMO;
        for cont_Antennas=1:2:MaxAntennas
            MIMO_CIR_N=Select_Number_Atennas_MIMO(MIMO_CIR,cont_Antennas);
            
            for cont_Order=1:numel(ModulationOrder);
            
            % Define Modulation............................................
            ModulationDefinition=struct;
            ModulationDefinition.Type='PSK';
            ModulationDefinition.BitsPerSymbol=ModulationOrder(cont_Order)*ones(1,cont_Antennas);
            ModulationDefinition.GrayCode='on';
            
            StreamLength=cont_Antennas*1000;
            % End Define Modulation........................................
            
            % Run Simulation
            
            Result=Simulate_Communication_Channel(Param,MIMO_CIR_N,...
                ModulationDefinition,NarrowbandFactor,inf,StreamLength);
            for cont_Time=1:numel(NarrowbandFactor)
                Resultados_MIMO_2{cont_Separation,cont_CIR,cont_Antennas,...
                    cont_Order,cont_Time}.GainVector=Result{cont_Time}.GainVector;
                Resultados_MIMO_2{cont_Separation,cont_CIR,cont_Antennas,...
                    cont_Order,cont_Time}.InterferenceNoise=Result{cont_Time}.InterferenceNoise;
            end % cont_Time
            
            
            cont_Completition=cont_Completition+1;
            Completition=100*(cont_Completition)/(numel(Separation)*NumberOfCIRS*...
                MaxAntennas*numel(ModulationOrder));
            fprintf(['Completition: ',num2str(Completition,'%.2f'),'%%\n'])
            end % cont_Ortder
        end % cont_Antennas
    end % cont_CIRS
end % cont_Separation
