%% Initialize

Input_Parameters
% Param.Spatial.AS_AOD_az=pi/2;
% Param.Spatial.AS_AOA_az=pi/2;
addpath functions
addpath Scripts
CIR=System_Generation(Param);
MIMO_CIR=CIR.MIMO;
Statistics_MIMO=Extract_MIMO_Statistics(MIMO_CIR);

NumClusters=4;

%% Obtain clusters

Clusters=Beamforming_Clusters(MIMO_CIR,NumClusters);
AOAMatrix=Clusters.BeamformingMatrixAOA;
AODMatrix=Clusters.BeamformingMatrixAOD;


%% New MIMO Structure

Beam_MIMO=struct;

Beam_MIMO.ReceiveAntennas=NumClusters;
Beam_MIMO.TransmitAntennas=NumClusters;
Beam_MIMO.Index=MIMO_CIR.Index;
Beam_MIMO.Time=MIMO_CIR.Time;
Beam_MIMO.AOA=MIMO_CIR.AOA;
Beam_MIMO.AOD=MIMO_CIR.AOD;

Beam_MIMO.H=cellfun(@(x) AOAMatrix*x*AODMatrix,MIMO_CIR.H,'UniformOutput',0);
Beam_MIMO.PDP=cellfun(@(x) x.*conj(x),Beam_MIMO.H,'UniformOutput',0);
Beam_MIMO.h=cell(NumClusters);

for cont1=1:NumClusters
    for cont2=1:NumClusters
        Beam_MIMO.h{cont1,cont2}=zeros(1,Beam_MIMO.Index(end));
        for cont3=1:length(Beam_MIMO.Index)
           Beam_MIMO.h{cont1,cont2}(Beam_MIMO.Index(cont3))=Beam_MIMO.H{cont3}(cont1,cont2);
        end
    end
end

%% Narrowband copmparison

H=cat(3,MIMO_CIR.H{:});
H=sum(H,3);
A=cat(3,Beam_MIMO.H{:});
A=sum(A,3);





