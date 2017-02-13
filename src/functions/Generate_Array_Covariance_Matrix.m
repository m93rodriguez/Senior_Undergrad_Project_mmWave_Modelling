function CovarianceMatrix=Generate_Array_Covariance_Matrix(Param,TimePositions,SpatialLobes)
%Generate the Transmit and Receive covariance matrixes from the input
%parameters, Time and Spatial structures.
% CovarianceMatrix=Generate_Array_Covariance_Matrix(Param,TimePositions,SpatialLobes)
TransmitCovariance=cell(1,length(TimePositions.TimeIndex));
ReceiveCovariance=TransmitCovariance;
for i=1:length(TimePositions.TimeIndex)
    TransmitCovariance{i}=ArrayCovarianceULA(SpatialLobes.MeanAOD(SpatialLobes.MeanAODIndex(i)),...
        Param.Correlation.AS_AOD_az,Param.System.Nt,Param.System.AntennaSeparation,Param.Phys.lambda);
    
    ReceiveCovariance{i}=ArrayCovarianceULA(SpatialLobes.MeanAOA(SpatialLobes.MeanAOAIndex(i)),...
        Param.Correlation.AS_AOA_az,Param.System.Nr,Param.System.AntennaSeparation,Param.Phys.lambda);
end
CovarianceMatrix=struct;
CovarianceMatrix.Transmit=TransmitCovariance;
CovarianceMatrix.Receive=ReceiveCovariance;

end