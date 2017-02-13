% Beamforming - Number of Cluster Count

Input_Parameters;
ClusterParam=[1 2 4 8 16];

for cont_Cluster=ClusterParam
    for cont_CIR=1:1000
        CIR=System_Generation(Param);
        MIMO_CIR=CIR.MIMO;
        while length(MIMO_CIR.Index)==1
            CIR=System_Generation(Param);
            MIMO_CIR=CIR.MIMO;
        end
        Statistics_MIMO=Extract_MIMO_Statistics(MIMO_CIR);
        [Angles,~]=Beamforming_Clusters(MIMO_CIR,Statistics_MIMO,...
            cont_Cluster);
        Results.AOD{cont_Cluster}(cont_CIR)=length(Angles.AOD);
        Results.AOA{cont_Cluster}(cont_CIR)=length(Angles.AOA);
    end
    cont_Cluster
end