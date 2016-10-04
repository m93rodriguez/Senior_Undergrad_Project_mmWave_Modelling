function SpatialLobes=Generate_Spatial_Properties(Param,TimePositions)
%Angle of departure and angle of arrival asignation
%SpatialLobes=Generate_Spatial_Properties(Param,TimePositions)

AODLobes=min([Param.MaxLobeNumber max([1,poissrnd(Param.MeanAODLobes)])]);
AOALobes=min([Param.MaxLobeNumber max([1,poissrnd(Param.MeanAOALobes)])]);

% Mean angle of departure
Mean_AOD=zeros(1,AODLobes);
for i=1:AODLobes
    AOD_min=360*(i-1)/AODLobes;
    AOD_max=360*i/AODLobes;
    Mean_AOD(i)=unifrnd(AOD_min,AOD_max);
end

% Mean angle of arrival
Mean_AOA=zeros(1,AOALobes);
for i=1:AOALobes
    AOA_min=360*(i-1)/AOALobes;
    AOA_max=360*i/AOALobes;
    Mean_AOA(i)=unifrnd(AOA_min,AOA_max);
end

MeanAODIndex=randi(AODLobes,size(TimePositions.TimeIndex));
MeanAOAIndex=randi(AOALobes,size(TimePositions.TimeIndex));

AOD=Mean_AOD(MeanAODIndex)+Param.AS_AOD_az*randn(size(MeanAODIndex));
AOA=Mean_AOA(MeanAOAIndex)+Param.AS_AOA_az*randn(size(MeanAOAIndex));

% Output Variable
SpatialLobes=struct;
SpatialLobes.AODLobes=AODLobes;
SpatialLobes.AOALobes=AOALobes;
SpatialLobes.MeanAOD=Mean_AOD;
SpatialLobes.MeanAOA=Mean_AOA;
SpatialLobes.MeanAODIndex=MeanAODIndex;
SpatialLobes.MeanAOAIndex=MeanAOAIndex;
SpatialLobes.AOD=AOD;
SpatialLobes.AOA=AOA;

end