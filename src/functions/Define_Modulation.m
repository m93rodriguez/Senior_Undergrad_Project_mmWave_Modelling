function ModulationDefinition=Define_Modulation(N_Tx,N_Rx,Duration,BitsPerSymbol,Type,GrayCode)
% Define Modulation Parameters for Communcation Channel Simulation
%   ModulationDefinition=Define_Modulation(N_Tx,N_Rx,Duration,BitsPerSymbol,
%   Type,GrayCode)
%   N_Tx: Number of Transmit Antennas
%   N_Rx: Number of Receive Antennas
%   Duration: Symbol Duration Index
%   BitsPerSymbol: Vector that indicates the modulation order for each data
%       stream. Must have the same number of elements than min(N_Tx,N_Rx).
%   Type: Two options exist: 'QAM', or 'PSK'
%   GrayCode: 'on' for using Gray code, 'off' else.
%
%   This function generates a structure that serves as input for other
%   functions in the communication channel simulation.

ModulationDefinition.BitsPerSymbol=BitsPerSymbol;
ModulationDefinition.Type=Type;
ModulationDefinition.GrayCode=GrayCode;

ModulationDefinition.ExcessTransmitAntennas=max(0,N_Tx-N_Rx);
ModulationDefinition.ExcessReceiveAntennas=max(0,N_Rx-N_Tx);
ModulationDefinition.SymbolDuration=Duration;
ModulationDefinition.PulseShape=ones(1,ModulationDefinition.SymbolDuration);

[ModulationDefinition.GrayCodeMapping,ModulationDefinition.GrayCodeUnmapping]...
    =Graycode_Constellation_Mapping(ModulationDefinition);
ModulationDefinition.ConstellationMap=cell(1,numel(ModulationDefinition.BitsPerSymbol));
ModulationDefinition.ConstellationEnergy=zeros(1,numel(ModulationDefinition.BitsPerSymbol));
for cont=1:numel(ModulationDefinition.BitsPerSymbol)
    [ModulationDefinition.ConstellationMap{cont},ModulationDefinition.ConstellationEnergy(cont)]=...
        Generate_Constellation_Map(ModulationDefinition.BitsPerSymbol(cont),...
        ModulationDefinition.Type);
    MinDistance=abs(ModulationDefinition.ConstellationMap{cont}-...
        ModulationDefinition.ConstellationMap{cont}(1));
    MinDistance=min(MinDistance(2:end))./sqrt(ModulationDefinition.ConstellationEnergy(cont));
    ModulationDefinition.MinDistance(cont)=MinDistance;
    
end
end