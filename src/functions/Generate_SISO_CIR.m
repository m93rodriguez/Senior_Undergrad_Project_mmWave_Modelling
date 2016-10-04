function h=Generate_SISO_CIR(TimePositions,MultipathPower,MultipathPhase)
%Generate Single-Input Single-Output Channel Impulse Response
% h=Generate_SISO_CIR(TimePositions,MultipathPower,MultipathPhase)

h=zeros(1,TimePositions.TimeIndex(end));
h(TimePositions.TimeIndex)=MultipathPower.Power.*exp(1i*MultipathPhase.Phase);
end