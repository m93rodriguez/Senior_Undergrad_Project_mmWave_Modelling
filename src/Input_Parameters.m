%% Parameter Definition

Param=struct;
%--------------------------------------------------------------------------        
% Physical derivations
Param.Phys.c=3e8;                   % Speed of light (m/s)
Param.Phys.f=60;                    % Carrier Frequency (GHz)
Param.Phys.lambda=Param.Phys.c/(Param.Phys.f*1e9);        % Wavelength (m)
%--------------------------------------------------------------------------
% Large scale parameters
Param.Large.Exponent=4.4;              % Path Loss Exponent
Param.Large.Shadowing=5;              % Shadowing factor (dB)
Param.Large.Distance=200;                  % TX-RX Distance (m)
Param.Large.Power=70;                  % Transmit Power (dB)
Param.Large.CloseIn=1;                   % Close in reference
%--------------------------------------------------------------------------
% System Definition
Param.System.Nt=16;                 % Number of transmit antennas
Param.System.Nr=16;                 % Number of recieve antennas
Param.System.BW=800;                % Bandpass Bandwidth (MHz)
Param.System.TimeResolution=2e3/Param.System.BW;         % Time resolution (ns)
Param.System.AntennaSeparation=Param.Phys.lambda/2;           % Antenna array separation
%--------------------------------------------------------------------------
% Statistical Parameters
% Time Cluster Statistics
Param.Time.MeanClusterNumber=2.5;                % Mean Number of Clusters
Param.Time.MeanSubclusterNumber=10;                 % Mean Number of MPC per Cluster
Param.Time.MeanClusterDelay=83;             % Mean cluster excess delay (ns)
Param.Time.ClusterSeparation=25;            % Minimum separation between clusters (ns)
        
Param.Time.ClusterPowerDecay=45.9;            % Decay constant for cluster power (ns)
Param.Time.ClusterLogPower=3;               % RMS power for cluster power (dB)
Param.Time.SubclusterPowerDecay=15;              % Decay constant for sub-cluster power (ns)
Param.Time.SubclusterLogPower=6;               % RMS power for sub-cluster power (dB)
Param.Time.SubclusterSeparation=0.2;                % For sub-cluster delay [Samimi et al. 2016]
        
% Spatial Lobes Statistics
Param.Spatial.MaxLobeNumber=5;              % Maximum number of arrival and departure spatial lobes
Param.Spatial.MeanAODLobes=1.5;           % Mean number of departure spatial lobes
Param.Spatial.MeanAOALobes=2.1;           % Mean number of arrival spatial lobes
Param.Spatial.AS_AOD_az=11;         % AOD azimutal angular spread (degrees)
Param.Spatial.AS_AOD_el=3;          % AOD elevation angular spread (degrees)
Param.Spatial.AS_AOA_az=7.5;        % AOA azimutal angular spread (degrees)
Param.Spatial.AS_AOA_el=6;          % AOA elevation angular spread (degrees)

