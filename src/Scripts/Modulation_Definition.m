BinaryDigits='01';
StreamLength=500;
Stream=BinaryDigits(randi(2,1,StreamLength));

ModulationDefinition=struct;
ModulationDefinition.BitsPerSymbol=5*ones(1,Param.System.Nt);
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


