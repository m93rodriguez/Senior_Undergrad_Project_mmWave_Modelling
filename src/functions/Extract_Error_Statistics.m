function Error=Extract_Error_Statistics(Stream,ModulationDefinition,Demodulation)

Error=struct;

OutputStream=Demodulation.Stream(1:length(Stream));
InSymbols=Bit_Multiplexing(Stream,ModulationDefinition);

Error.TotalBitError=sum(abs(Stream-OutputStream))/length(Stream);

Error.InSymbols=InSymbols;
Error.OutSymbols=Demodulation.OutSymbol;

for cont=1:length(Demodulation.OutSymbol)
    Error.SymbolError{cont}=sum(abs(InSymbols(cont,:)...
        -Demodulation.OutSymbol{cont}(1:length(InSymbols))))/length(InSymbols);
    
    InSymbolStream=dec2bin(InSymbols(cont,:)-1,ModulationDefinition.BitsPerSymbol(cont));
    InSymbolStream=InSymbolStream';
    InSymbolStream=InSymbolStream(:)';
    OutSymbolStream=dec2bin(Demodulation.OutSymbol{cont}-1,ModulationDefinition.BitsPerSymbol(cont));
    OutSymbolStream=OutSymbolStream';
    OutSymbolStream=OutSymbolStream(:)';
    OutSymbolStream=OutSymbolStream(1:length(InSymbolStream));
    
    Error.BitError{cont}=sum(abs(InSymbolStream-OutSymbolStream))/length(InSymbolStream);
end

end