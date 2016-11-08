%% Process Experiment MIMO 1 Results

% Variable Structure:
% Resultados_MIMO_1 - 3D cell
% - Dimension 1: Antenna Separation
% - Dimension 2: CIR Number
% - Dimension 3: NUmber of Antennas

% For each position, there are a number of cells related to the number of
% Narowband Factors

% Resultados_MIMO_1{Separation,CIR,Antenna}{Time Factor}

% For each of these positions,  there is a structure with fields:

%   - ErrorStatistics: Structure: Bit and Symbol Error with Symbols
%   - Demodulation: Structure: Symbol Positions
%   - GainVector: Vector with dimension equal to number of antennas
%   - InterferenceNoise: 3 columns, rows equal to number of Antennas
%       (cell) - First column is a vector with the symbol positions minus
%       the mean, second column is the null-hypothesis and p-value for the
%       real part and the third column same numbers but for the imaginary
%       part.

%% Set up Intervals

% First Fields
Separation=1:10; %Separation*lambda/2
MaxCIR=30;
MaxAntennas=16;

% Second Fields
NarrowbandFactor=10:10:100;

%% Probability
Antenna=16;
Factor=10;
Prob=[];
for cont_Antenna=1:Antenna
    for cont=1:MaxCIR
        Var=Resultados_MIMO_1{1,cont,Antenna}{Factor}.InterferenceNoise{cont_Antenna,2};
        Prob(cont,1,cont_Antenna)=Var(1);
        P_Val(cont,1,cont_Antenna)=Var(2);
        Var=Resultados_MIMO_1{1,cont,Antenna}{Factor}.InterferenceNoise{cont_Antenna,3};
        Prob(cont,2,cont_Antenna)=Var(1);
        P_Val(cont,2,cont_Antenna)=Var(2);
    end
end

Prob=permute(mean(Prob,1),[3,2,1]);

%% Plot


Antenna=9;
Factor=1;
Var=Resultados_MIMO_1{1,25,Antenna}{Factor}.InterferenceNoise{1,1};

scatter(real(Var),imag(Var))

