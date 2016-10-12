function Symbol=Bit_Multiplexing(Stream,BitsPerSymbol)

NumAntennas=length(BitsPerSymbol);
BitsPerPeriod=sum(BitsPerSymbol);
NumPeriods=ceil(numel(Stream)/BitsPerPeriod);

while numel(Stream)<NumPeriods*BitsPerPeriod
    Stream=[Stream '0'];
end

for cont=1:NumPeriods
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