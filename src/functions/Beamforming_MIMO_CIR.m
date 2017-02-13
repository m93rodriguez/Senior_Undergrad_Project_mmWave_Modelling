function Beam_MIMO=Beamforming_MIMO_CIR(Clusters,MIMO_CIR)

% Generate MIMO Channel Impulse Response using Beamforming
%   Beam_MIMO=Beamforming_MIMO_CIR(CLusters,MIMO_CIR) gives a new MIMO
%   Channel Impulse Response by applying the Beamforming parameters
%   contained in Clusters to an existing MIMO CIR. Clusters is a structure
%   variable that is calculated using the Beamforming_Clusters function.
%   Beam_MIMO is a structure variable that have the fields that the
%   MIMO_CIR variable.

NumClusters=numel(Clusters.AOD);

AOAMatrix=Clusters.BeamformingMatrixAOA;
AODMatrix=Clusters.BeamformingMatrixAOD;

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

Beam_MIMO.Narrowband=sum(cat(3,Beam_MIMO.H{:}),3);

end