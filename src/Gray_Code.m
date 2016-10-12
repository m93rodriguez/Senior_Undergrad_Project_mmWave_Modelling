NumBits=4;
type='QAM';

if strcmp(type,'QAM')
    NumBits=NumBits/2;
end

Bits={'0','1'};
N=length(Bits);

while N<NumBits^2
    Bits2=flip(Bits);
    
    for i=1:N
        Bits{i}=['0' Bits{i}];
        Bits2{i}=['1' Bits2{i}];
    end
    Bits=[Bits Bits2];
    N=length(Bits);
end

if strcmp(type,'QAM')
    QAM=cell(length(Bits));
    for cont1=1:length(Bits);
        for cont2=1:cont1
            QAM{cont1,cont2}=[Bits{cont1} Bits{cont2}];
            QAM{cont2,cont1}=[Bits{cont2} Bits{cont1}];
        end
    end
    Bits=QAM(:);
end

Bits=cellfun(@bin2dec,Bits)+1;
[~,Bits]=sort(Bits);
