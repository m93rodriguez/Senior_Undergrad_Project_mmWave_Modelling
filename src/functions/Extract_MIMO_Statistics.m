function Statistics=Extract_MIMO_Statistics(MIMO_CIR)
% Extract MIMO Channel Impulse Response Time Statistics
% Statistics=Extract_MIMO_Statistics(MIMO_CIR). MIMO_CIR is a structure
% variable that contains the description of the MIMO Channel, as given by
% the function System_Generation. Statistics is a structure that contains
% information about the time spread of the channel.

MeanTime=zeros(1,numel(MIMO_CIR.h));
RMSTime=MeanTime;

for cont=1:numel(MIMO_CIR.h)    
    PDP=MIMO_CIR.h{cont}(MIMO_CIR.Index);
    PDP=PDP.*conj(PDP);
    MeanTime(cont)=sum(PDP.*MIMO_CIR.Time)/sum(PDP);
    RMSTime(cont)=sqrt(sum((MIMO_CIR.Time-MeanTime(cont)).^2.*PDP)/sum(PDP));
end

Statistics=struct;
Statistics.MeanTime=MeanTime;
Statistics.RMSTime=RMSTime;
Statistics.MeanRMS=mean(RMSTime);
Statistics.LimitsRMS=[min(RMSTime) max(RMSTime)];
end
