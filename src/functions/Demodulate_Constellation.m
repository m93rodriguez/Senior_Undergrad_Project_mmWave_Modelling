function OutputBit=Demodulate_Constellation(ConstellationMap,SymbolStream)

OutputBit=zeros(size(SymbolStream));
for cont=1:length(SymbolStream)
    Distance=abs(SymbolStream(cont)-ConstellationMap);
    [~,I]=min(Distance);
    OutputBit(cont)=I;
end
end
