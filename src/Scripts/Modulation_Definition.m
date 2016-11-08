BinaryDigits='01';
StreamLength=5000;
Stream=BinaryDigits(randi(2,1,StreamLength));

ModulationDefinition=struct;

ModulationDefinition.BitsPerSymbol=2*ones(1,min(Param.System.Nt,Param.System.Nr));
ModulationDefinition.ExcessTransmitAntennas=max(0,Param.System.Nt-Param.System.Nr);
ModulationDefinition.ExcessReceiveAntennas=max(0,Param.System.Nr-Param.System.Nt);

ModulationDefinition.SymbolDuration=Index_Duration;
ModulationDefinition.PulseShape=ones(1,ModulationDefinition.SymbolDuration);
ModulationDefinition.Type='PSK';

ModulationDefinition.GrayCode='on';
[ModulationDefinition.GrayCodeMapping,ModulationDefinition.GrayCodeUnmapping]...
    =Graycode_Constellation_Mapping(ModulationDefinition);
ModulationDefinition.ConstellationMap=cell(1,numel(ModulationDefinition.BitsPerSymbol));
ModulationDefinition.ConstellationEnergy=zeros(1,numel(ModulationDefinition.BitsPerSymbol));
for cont=1:numel(ModulationDefinition.BitsPerSymbol)
    [ModulationDefinition.ConstellationMap{cont},ModulationDefinition.ConstellationEnergy(cont)]=...
        Generate_Constellation_Map(ModulationDefinition.BitsPerSymbol(cont),...
        ModulationDefinition.Type);
end


