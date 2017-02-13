function [SymbolMapping,SymbolUnmapping]=Graycode_Constellation_Mapping(ModulationDefinition)

NumAntennas=numel(ModulationDefinition.BitsPerSymbol);
SymbolMapping=cell(1,NumAntennas);
SymbolUnmapping=cell(1,NumAntennas);
for cont=1:NumAntennas
    NumBits=ModulationDefinition.BitsPerSymbol(cont);
    type=ModulationDefinition.Type;
    
    if strcmp(type,'PSK') || NumBits==1
        Bits=Generate_Graycode(NumBits);
    elseif strcmp(type,'QAM')
        Bits_X=Generate_Graycode(ceil(NumBits/2));
        Bits_Y=Generate_Graycode(floor(NumBits/2));
        QAM=cell(length(Bits_Y),length(Bits_X));
        
        for x=1:length(Bits_X)
            for y=1:length(Bits_Y)
                QAM{y,x}=[Bits_Y{y} Bits_X{x}];
            end
        end
        Bits=QAM(:)';
        
%     elseif strcmp(type,'PSK')
%         Bits=Generate_Graycode(NumBits);
    end
    
    SymbolUnmapping{cont}=cellfun(@bin2dec,Bits)+1;
    [~,SymbolMapping{cont}]=sort(SymbolUnmapping{cont});
    SymbolMapping{cont}=SymbolMapping{cont};
end

end
