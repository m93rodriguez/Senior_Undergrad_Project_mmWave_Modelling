function MultipathPhase=Generate_Phase(TimePositions)
%Multipath phases
% MultipathPhase=Generate_Phase(TimePositions)

SubclusterPhase=cell(1,TimePositions.Cluster);
for i=1:TimePositions.Cluster
    SubclusterPhase{i}=2*pi*rand(1,TimePositions.Subcluster(i));
end
Phase=[SubclusterPhase{:}];

MultipathPhase=struct;
MultipathPhase.SubclusterPhase=SubclusterPhase;
MultipathPhase.Phase=Phase;
end