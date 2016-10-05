function Statistics=Extract_MIMO_Statistics(MIMO_CIR)

PDP=zeros(length(MIMO_CIR.h{:}),MIMO_CIR.Index(end));

for i=1:length(MIMO_CIR.h{:})
    PDP(i,:)=MIMO_CIR.h{i}.*MIMO_CIR.h{i}';
end

PDP=

end