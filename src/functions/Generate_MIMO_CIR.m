function MIMO_CIR=Generate_MIMO_CIR(System,CovarianceMatrix,MultipathPower,MultipathPhase,...
    TimePositions,SpatialLobes)
%Calculate Multiple-Input Multiple-Output system channel impulse response.
% MIMO_CIR=Generate_MIMO_CIR(System,CovarianceMatrix,MultipathPower,MultipathPhase);

H=cell(1,length(MultipathPower.Amplitude));
PDP=H;
for i=1:length(MultipathPower.Amplitude)
    Rayleigh_iid_Matrix=randn(System.Nr,System.Nt)+1i*randn(System.Nr,System.Nt);
    [Vector_r,Value_r]=eig(CovarianceMatrix.Receive{i});
    [Vector_t,Value_t]=eig(CovarianceMatrix.Transmit{i});
    
    H{i}=Vector_r*sqrt(Value_r)*Rayleigh_iid_Matrix*sqrt(Value_t)*Vector_t';
    H{i}=MultipathPower.Amplitude(i)*exp(1i*MultipathPhase.Phase(i))*H{i};
    PDP{i}=H{i}.*conj(H{i}); 
end
MIMO_CIR.ReceiveAntennas=System.Nr;
MIMO_CIR.TransmitAtennas=System.Nt;
MIMO_CIR.Index=TimePositions.TimeIndex;
MIMO_CIR.H=H;
MIMO_CIR.Time=TimePositions.ExcessTime;
MIMO_CIR.AOA=SpatialLobes.AOA;
MIMO_CIR.AOD=SpatialLobes.AOD;
MIMO_CIR.PDP=PDP;

h=cell(System.Nr,System.Nt);
n=1:TimePositions.TimeIndex(end);
for i=1:System.Nr
    for j=1:System.Nt
        h{i,j}=zeros(size(n));
        for cont=1:length(TimePositions.TimeIndex)
            h{i,j}(cont)=H{cont}(i,j);
        end
    end
end

MIMO_CIR.h=h;

end