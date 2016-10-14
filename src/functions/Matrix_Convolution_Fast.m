function y=Matrix_Convolution_Fast(x,MIMO_CIR)

Index=MIMO_CIR.Index;
H=MIMO_CIR.H;
Time=size(x,2);

y=zeros(MIMO_CIR.ReceiveAntennas,size(x,2)+Index(end)-1);

for cont=1:length(H)
    g=zeros(size(y));
    g(:,Index(cont):Index(cont)+Time-1)=H{cont}*x;
    y=y+g;
end


end