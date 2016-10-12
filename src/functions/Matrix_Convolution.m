function y=Matrix_Convolution(x,MIMO_CIR)

Index=MIMO_CIR.Index;

H=cell(1,Index(end));

for cont=1:Index(end)
    if sum(Index==cont)==0
        H{cont}=zeros(MIMO_CIR.ReceiveAntennas,MIMO_CIR.TransmitAtennas);
    else
        H{cont}=MIMO_CIR.H{Index==cont};
    end
end

y=zeros(MIMO_CIR.ReceiveAntennas,size(x,2)+length(H)-1);

for n=1:size(x,2)+length(H)-1
    for k=max(1,n+1-length(H)):min(n,size(x,2))
        y(:,n)=y(:,n)+H{n-k+1}*x(:,k);
    end
end

end