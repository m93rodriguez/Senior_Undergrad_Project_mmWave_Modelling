function H=Generate_MIMO_CIR(System,CovarianceMatrix,MultipathPower,MultipathPhase)
%Calculate Multiple-Input Multiple-Output system channel impulse response.
% H=Generate_MIMO_CIR(System,CovarianceMatrix,MultipathPower,MultipathPhase);

H=cell(1,length(MultipathPower.Amplitude));
for i=1:length(MultipathPower.Amplitude)
    Rayleigh_iid_Matrix=randn(System.Nr,System.Nt)+1i*randn(System.Nr,System.Nt);
    [Vector_r,Value_r]=eig(CovarianceMatrix.Receive{i});
    [Vector_t,Value_t]=eig(CovarianceMatrix.Transmit{i});
    
    H{i}=Vector_r*sqrt(Value_r)*Rayleigh_iid_Matrix*sqrt(Value_t)*Vector_t';
    H{i}=MultipathPower.Amplitude(i)*exp(1i*MultipathPhase.Phase(i))*H{i};
    
end

end