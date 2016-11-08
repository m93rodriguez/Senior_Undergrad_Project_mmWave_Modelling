%% Process Experiment MIMO (ALL) Results

% Variable Structure:
% Resultados_MIMO - 5D cell
% - 1: Antenna Separation 1:2:10 (half lambda) (5)
% - 2: CIR count (30)
% - 3: Number of Antennas 1:2:16 (8)
% - 4: Modulation Order (3)
% - 5: Narrowband Factor 10:20:100 (5)

% Each position is a structure with fields:
% - GainVector: Size 1 x Number of Antennas
% - Interference Noise: cell Number of Antennas x 3
%   - Each row is an Antenna
%   - Column 1: Dispersion of demodulated points
%   - Column 2: In-Phase Null-Hypothesis and p-value
%   - Column 3: Quadrature Null-Hypothesis and p-value

%% Set up Intervals

Separation=1:2:10; % Units: lambda/2
CIR=1:30;
Antennas=1:2:16;
ModulationOrder=1:3;
Narrowband=10:20:100;

%% Gaussianity Test

Distance=5; % Max 5
AntennaCluster=2; %Max 8
Order=3;
Factor=3; % Max 5

for cont_CIR=CIR
    Prob_aux=Resultados_MIMO{Distance,cont_CIR,AntennaCluster,Order,Factor}...
        .InterferenceNoise{AntennaCluster,2}(1);
    Prob(cont_CIR)=Prob_aux;
end
Prob
