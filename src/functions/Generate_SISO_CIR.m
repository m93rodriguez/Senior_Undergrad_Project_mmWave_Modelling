function SISO_CIR=Generate_SISO_CIR(System,TimePositions,MultipathPower,MultipathPhase,SpatialLobes)
%Generate Single-Input Single-Output Channel Impulse Response
% h=Generate_SISO_CIR(TimePositions,MultipathPower,MultipathPhase)

SISO_CIR=struct;

n=1:TimePositions.TimeIndex(end);

h=zeros(1,TimePositions.TimeIndex(end));
h(TimePositions.TimeIndex)=MultipathPower.Power.*exp(1i*MultipathPhase.Phase);

Time=(n-1)*System.TimeResolution;

AOD=zeros(size(n));
AOA=AOD;
AOD(TimePositions.TimeIndex)=SpatialLobes.AOD;
AOA(TimePositions.TimeIndex)=SpatialLobes.AOA;

SISO_CIR.Index=TimePositions.TimeIndex;
SISO_CIR.h=h;
SISO_CIR.Time=Time;
SISO_CIR.AOD=AOD;
SISO_CIR.AOA=AOA;
SISO_CIR.PDP=h.*conj(h);

end