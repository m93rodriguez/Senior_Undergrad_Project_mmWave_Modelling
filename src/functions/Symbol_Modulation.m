function Modulation=Symbol_Modulation(Symbol,ModulationDefinition)


BitsPerSymbol=ModulationDefinition.BitsPerSymbol;
SymbolDuration=ModulationDefinition.SymbolDuration;
Type=ModulationDefinition.Type;
GrayCode=ModulationDefinition.GrayCode;

NumAntennas=numel(BitsPerSymbol);
NumSymbols=size(Symbol,2);

Map=cell(1,NumAntennas);

for cont=1:NumAntennas
    Map{cont}=Generate_Constellation_Map(BitsPerSymbol(cont),Type);
end

Signal=[];
for cont=1:NumSymbols
    for antenna=1:NumAntennas
        Mod(antenna,:)=Map{antenna}(Symbol(antenna,cont))*ones(1,SymbolDuration);
    end
    Signal=[Signal Mod];
end


Modulation.Map=Map;
Modulation.Signal=Signal;
    

end