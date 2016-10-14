function [SymbolMapping,SymbolUnmapping]=Graycode_Constellation_Mapping(ModulationDefinition)

NumAntennas=numel(ModulationDefinition.BitsPerSymbol);
SymbolMapping=cell(1,NumAntennas);
SymbolUnmapping=cell(1,NumAntennas);
for cont=1:NumAntennas
    NumBits=ModulationDefinition.BitsPerSymbol(cont);
    type=ModulationDefinition.Type;
    
    if strcmp(type,'QAM')
        Bits_X=Generate_Graycode(ceil(NumBits/2));
        Bits_Y=Generate_Graycode(floor(NumBits/2));
        QAM=cell(length(Bits_Y),length(Bits_X));
        
        for x=1:length(Bits_X)
            for y=1:length(Bits_Y)
                QAM{y,x}=[Bits_Y{y} Bits_X{x}];
            end
        end
        Bits=QAM(:);
        
    elseif strcmp(type,'PSK')
        Bits=Generate_Graycode(NumBits);
    end
    %%
%     if strcmp(type,'QAM')
%         NumBits=ceil(NumBits/2);
%     end
%     
%     Bits={'0','1'};
%     N=length(Bits);
%     
%     while N<2^NumBits
%         Bits2=flip(Bits);
%         
%         for i=1:N
%             Bits{i}=['0' Bits{i}];
%             Bits2{i}=['1' Bits2{i}];
%         end
%         Bits=[Bits Bits2];
%         N=length(Bits);
%     end
%     
%     if strcmp(type,'QAM')
%         
%         QAM=cell(length(Bits));
%         for cont1=1:length(Bits);
%             for cont2=1:cont1
%                 QAM{cont1,cont2}=[Bits{cont1} Bits{cont2}];
%                 QAM{cont2,cont1}=[Bits{cont2} Bits{cont1}];
%             end
%         end
%         Bits=QAM(:);
%     end
    %%
    
    SymbolUnmapping{cont}=cellfun(@bin2dec,Bits)+1;
    [~,SymbolMapping{cont}]=sort(SymbolUnmapping{cont});
    SymbolMapping{cont}=SymbolMapping{cont};
end

end
