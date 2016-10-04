function MultipathPower=Generate_Power(TimePositions,Param)
%Power calculation for multipath components
% MultipathPower=Generate_Power(TimePositions,Param). Param corresponds to
% Param.Time in the input parameters script.

% Cluster Powers - Normalized, Linear Units
ClusterPower=exp(-TimePositions.ClusterDelays/Param.ClusterPowerDecay)...
    .*10.^(normrnd(0,Param.ClusterLogPower,1,TimePositions.Cluster)/10);
ClusterPower=ClusterPower/sum(ClusterPower);

% Subcluster Powers - Normalized, Linear Units
% Power - Normalized, Linear Units

SubclusterPower=cell(1,TimePositions.Cluster);
Power=[];

for i=1:TimePositions.Cluster
    SubclusterPower{i}=exp(-TimePositions.SubclusterDelays{i}/Param.SubclusterPowerDecay)...
        .*10.^(normrnd(0,Param.SubclusterLogPower,1,TimePositions.Subcluster(i))/10);
    SubclusterPower{i}=ClusterPower(i)*SubclusterPower{i}/sum(SubclusterPower{i});
    Power=[Power SubclusterPower{i}];
end

% Amplitudes
Amplitude=sqrt(Power);

% Output Variable
MultipathPower=struct;
MultipathPower.ClusterPower=ClusterPower;
MultipathPower.SubclusterPower=SubclusterPower;
MultipathPower.Power=Power;
MultipathPower.Amplitude=Amplitude;

end