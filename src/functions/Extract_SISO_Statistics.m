function Statistics=Extract_SISO_Statistics(SISO_CIR)

MeanDelaySpread=sum(SISO_CIR.Time.*SISO_CIR.PDP)/sum(SISO_CIR.PDP);
RMSDelaySpread=sqrt(sum((SISO_CIR.Time-MeanDelaySpread).^2.*SISO_CIR.PDP)...
    /sum(SISO_CIR.PDP));
MaxExcessDelay=SISO_CIR.Time(end);

Statistics=struct;
Statistics.MeanDelaySpread=MeanDelaySpread;
Statistics.RMSDelaySpread=RMSDelaySpread;
Statistics.MaxExcessDelay=MaxExcessDelay;
end