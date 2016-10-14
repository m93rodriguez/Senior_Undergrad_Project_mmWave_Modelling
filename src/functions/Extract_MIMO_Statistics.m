function Statistics=Extract_MIMO_Statistics(MIMO_CIR)

PDP=zeros(length(MIMO_CIR.h(:)),length(MIMO_CIR.Index));

for i=1:length(MIMO_CIR.h(:))
    h=MIMO_CIR.h{i};
    h=h(MIMO_CIR.Index);
    PDP(i,:)=h.*conj(h);
end

PDP=mean(PDP,1);



MeanDelaySpread=sum(MIMO_CIR.Time.*PDP)/sum(PDP);

RMSDelaySpread=sqrt(sum((MIMO_CIR.Time-MeanDelaySpread).^2.*PDP)/sum(PDP));

Statistics=struct;
Statistics.MeanDelaySpread=MeanDelaySpread;
Statistics.RMSDelaySpread=RMSDelaySpread;
Statistics.MaxExcessDelay=MIMO_CIR.Time(end);

end