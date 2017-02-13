function Statistics=Extract_MIMO_Statistics(MIMO_CIR)
% Extract MIMO Channel Impulse Response Time Statistics
% Statistics=Extract_MIMO_Statistics(MIMO_CIR). MIMO_CIR is a structure
% variable that contains the description of the MIMO Channel, as given by
% the function System_Generation. Statistics is a structure that contains
% information about the time spread of the channel.
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