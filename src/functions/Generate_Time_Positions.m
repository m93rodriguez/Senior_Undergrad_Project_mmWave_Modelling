function TimePositions=Generate_Time_Positions(Param,System,N,M)
%Time information for wireless channel
% TimePositions=Generate_Time_Positions(Param,System,N,M) generates the
% structure TimePositions with fields:
% Cluster (Number of Clusters), Subcluster (Number of Subclusters),
% ClusterDelays (Vector with the cluster excess delay information),
% SubclusterDelays (Cell of vectors with subcluster excess delay
% information), ExcessTime (Vector with overall time information),
% TimeIndex (vector of integers). The inputs are the number of clusters N,
% number of subcluster for each cluster M, ans the structures of parameters
% Param.Time and Param.System respectively.

% Subcluster delays
SubclusterDelays=cell(1,N);
for i=1:N
    SubclusterDelays{i}=(((1:M(i))-1)/(System.BW/2)*1000).^(1+...
        Param.SubclusterSeparation*rand);
end

% Cluster delays
ClusterDelays=exprnd(Param.MeanClusterDelay,1,N);
ClusterDelays=sort(ClusterDelays)-min(ClusterDelays);
for i=2:N
    ClusterDelays(i)=ClusterDelays(i-1)+SubclusterDelays{i-1}(end)+...
        ClusterDelays(i)+Param.ClusterSeparation;
end

% Absolute Time
ExcessTime=[];
for i=1:N
    ExcessTime=[ExcessTime ClusterDelays(i)+SubclusterDelays{i}];
end

TimeIndex=round(ExcessTime/System.TimeResolution)+1;

% Output Variable
TimePositions=struct;
TimePositions.Cluster=N;
TimePositions.Subcluster=M;
TimePositions.ClusterDelays=ClusterDelays;
TimePositions.SubclusterDelays=SubclusterDelays;
TimePositions.ExcessTime=ExcessTime;
TimePositions.TimeIndex=TimeIndex;

end