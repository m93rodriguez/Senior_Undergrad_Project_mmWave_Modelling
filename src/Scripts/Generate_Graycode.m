function Bits=Generate_Graycode(NumBits)

Bits={'0','1'};
N=length(Bits);

while N<2^NumBits
    Bits2=flip(Bits);
    for i=1:N
        Bits{i}=['0' Bits{i}];
        Bits2{i}=['1' Bits2{i}];
    end
    Bits=[Bits Bits2];
    N=length(Bits);
end

end