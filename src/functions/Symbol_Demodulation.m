function Demodulation=Symbol_Demodulation(Signal,ChannelGain,ModulationDefinition)

MatchedFilter=ModulationDefinition.PulseShape;
SymbolDuration=ModulationDefinition.SymbolDuration;
SymbolEnergy=ModulationDefinition.ConstellationEnergy;
ConstellationMap=ModulationDefinition.ConstellationMap;
GrayCodeUnmapping=ModulationDefinition.GrayCodeUnmapping;
BitsPerSymbol=ModulationDefinition.BitsPerSymbol;

Signal=Signal(1:end-ModulationDefinition.ExcessReceiveAntennas,:);

Demodulation=struct;

NumAntennas=size(Signal,1);
BitStream=cell(1,NumAntennas);

for cont=1:NumAntennas
    DetectedSymbol=conv(Signal(cont,:),MatchedFilter/SymbolDuration);
    DetectedSymbol=DetectedSymbol*sqrt(SymbolEnergy(cont))/ChannelGain(cont,cont);
    Sampling=SymbolDuration:SymbolDuration:length(DetectedSymbol);
    DetectedSymbol=DetectedSymbol(Sampling);
    DetectedSymbol=DetectedSymbol(1:end);
    Demodulation.SymbolPosition{cont}=DetectedSymbol;
    DetectedSymbol=Demodulate_Constellation(ConstellationMap{cont},DetectedSymbol);
    DetectedSymbol=GrayCodeUnmapping{cont}(DetectedSymbol)-1;
    Demodulation.OutSymbol{cont}=DetectedSymbol+1;
    
    BitStream{cont}=dec2bin(DetectedSymbol,BitsPerSymbol(cont));
    
end

Stream=[];
AntennaStream=cell(NumAntennas,1);
for NumSymbol=1:length(DetectedSymbol)
    for cont=1:NumAntennas
        Stream=[Stream BitStream{cont}(NumSymbol,:)];
        AntennaStream{cont}=[AntennaStream{cont} BitStream{cont}(NumSymbol,:)];
    end
end

Demodulation.Stream=Stream;
Demodulation.AntennaStream=AntennaStream;
end