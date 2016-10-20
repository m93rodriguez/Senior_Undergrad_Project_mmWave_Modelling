function Signal=Symbol_Modulation(Stream,ModulationDefinition)

%% Read Modulation Characteristics
BitsPerSymbol=ModulationDefinition.BitsPerSymbol;
SymbolDuration=ModulationDefinition.SymbolDuration;
Type=ModulationDefinition.Type;
GrayCode=ModulationDefinition.GrayCode;
GrayCodeMap=ModulationDefinition.GrayCodeMapping;
ConstellationMap=ModulationDefinition.ConstellationMap;

NumAntennas=numel(BitsPerSymbol);
BitsPerPeriod=sum(BitsPerSymbol);
NumSymbols=ceil(numel(Stream)/BitsPerPeriod);

%% Bit Multiplexing

Symbol=Bit_Multiplexing(Stream,ModulationDefinition);
%% Signal Modulation

NumSymbols=size(Symbol,2);

Signal=[];
for cont=1:NumSymbols
    for antenna=1:NumAntennas
        Mod(antenna,:)=ConstellationMap{antenna}(GrayCodeMap{antenna}(Symbol(antenna,cont)))...
            *ones(1,SymbolDuration);
        % Energy Normalization
        Mod(antenna,:)=Mod(antenna,:)/sqrt(ModulationDefinition.ConstellationEnergy(antenna));
    end
    Signal=[Signal Mod];
end
Inactive=zeros(ModulationDefinition.ExcessTransmitAntennas,size(Signal,2));
Signal=[Signal;Inactive];
end