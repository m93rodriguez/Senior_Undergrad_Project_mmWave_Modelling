function Symbol=Bit_Multiplexing(Stream,ModulationDefinition)

BitsPerSymbol=ModulationDefinition.BitsPerSymbol;
BitsPerPeriod=sum(BitsPerSymbol);
NumAntennas=numel(BitsPerSymbol);
NumSymbols=ceil(numel(Stream)/BitsPerPeriod);


% Complete de Stream Length
while numel(Stream)<NumSymbols*BitsPerPeriod
    Stream=[Stream '0'];
end

% Separate bits to each antenna according to the modulation length
for cont=1:NumSymbols
    for antenna=1:NumAntennas
        if BitsPerSymbol(antenna)==0
            continue
        else
            StreamSec=Stream(1:BitsPerSymbol(antenna));
            Symbol(antenna,cont)=bin2dec(StreamSec);
            Stream=Stream(BitsPerSymbol(antenna)+1:end);
        end
    end
end

Symbol=Symbol+1;

end