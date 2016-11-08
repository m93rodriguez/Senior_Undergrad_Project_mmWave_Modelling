%% Experiment MIMO - 1

% Determine the effects of the Interference Noise
% Input Variables:
% - Number of Antennas
% - Narrowband Factor
% - Antenna Spacing
% - Delay Spread

% Output Variable
% - Noise Amplitud
% - Gaussianity (h, and p-value)

%% Parameters

NumberOfCIRS=30;
NarrowbandFactor=10:10:100;
MaxAntennas=16;
Separation=1:10;

%% Set up System

Input_Parameters
addpath functions
addpath Scripts
addpath Experiments

% Resultados_MIMO_1=struct;

Param.System.Nt=MaxAntennas;
Param.System.Nr=MaxAntennas;
cont_Completition=0;
for cont_Separation=Separation
    Param.System.AntennaSeparation=Param.Phys.lambda*Separation(cont_Separation)/2;
    for cont_CIR=1:NumberOfCIRS
        CIR=System_Generation(Param);
        MIMO_CIR=CIR.MIMO;
        for cont_Antennas=1:MaxAntennas
            MIMO_CIR_N=Select_Number_Atennas_MIMO(MIMO_CIR,cont_Antennas);
            
            % Define Modulation............................................
            ModulationDefinition=struct;
            ModulationDefinition.Type='PSK';
            ModulationDefinition.BitsPerSymbol=1*ones(1,cont_Antennas);
            ModulationDefinition.GrayCode='on';
            
            StreamLength=cont_Antennas*1000;
            % End Define Modulation........................................
            
            % Run Simulation
            Resultados_MIMO_1{cont_Separation,cont_CIR,cont_Antennas}=...
                Simulate_Communication_Channel(Param,MIMO_CIR_N,...
                ModulationDefinition,NarrowbandFactor,inf,StreamLength);
            
            cont_Completition=cont_Completition+1;
            Completition=100*(cont_Completition)/(numel(Separation)*NumberOfCIRS*...
                MaxAntennas);
            fprintf(['Completition: ',num2str(Completition,'%.2f'),'%%\n'])
        end % cont_Antennas
    end % cont_CIRS
end % cont_Separation

