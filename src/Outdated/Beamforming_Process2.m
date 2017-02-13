%% Initialize

Input_Parameters
Param.Spatial.AS_AOD_az=0.00001;
Param.Spatial.AS_AOA_az=0.00001;
addpath functions
addpath Scripts

CIR=System_Generation(Param);
MIMO_CIR=CIR.MIMO;
Statistics_MIMO=Extract_MIMO_Statistics(MIMO_CIR);

%% Beamforming Paramteres

MaxAntennas=MIMO_CIR.TransmitAntennas;
NumClusters=2;
AntennasPerCluster=round(MaxAntennas/NumClusters);

[Angles,Cost]=Beamforming_Clusters(MIMO_CIR,Statistics_MIMO,AntennasPerCluster);

String={'AOD','AOA'};
ClusterAngle=struct;
for Direction=[1,2]
    N=length(Cost.(String{Direction}));
    
    ClusterAngle.(String{Direction})=zeros(1,NumClusters);
    
    if NumClusters<N
            ClusterAngle.(String{Direction})=Angles.(String{Direction})(1:NumClusters);
    else
        aux=1;
        for cont=1:NumClusters
            if aux>N;
                aux=1;
            end
            ClusterAngle.(String{Direction})(cont)=Angles.(String{Direction})(aux);
            aux=aux+1;
        end
    end
    
end

%% Departure matrix

BeamformingMatrix=struct;

BeamformingMatrix.AOD=zeros(MaxAntennas,NumClusters);

for cont=1:NumClusters
    Shift=exp(1i*(0:AntennasPerCluster-1)'*pi*sin(ClusterAngle.AOD(cont)));
    BeamformingMatrix.AOD((cont-1)*AntennasPerCluster+1:AntennasPerCluster*cont,...
        cont)=Shift;
end
% BeamformingMatrix.AOD=exp(1i*BeamformingMatrix.AOD);

%% Arrival matrix

BeamformingMatrix.AOA=zeros(MaxAntennas,NumClusters);

for cont=1:NumClusters
    Shift=exp(1i*(0:AntennasPerCluster-1)'*pi*sin(ClusterAngle.AOA(cont)));
    BeamformingMatrix.AOA((cont-1)*AntennasPerCluster+1:AntennasPerCluster*cont,...
        cont)=Shift;
end
BeamformingMatrix.AOA=(BeamformingMatrix.AOA).';

%%
A=zeros(length(NumClusters));
H=zeros(MaxAntennas);
for cont=1:length(MIMO_CIR.Index)
    A=A+BeamformingMatrix.AOA*MIMO_CIR.H{cont}*BeamformingMatrix.AOD;
    H=H+MIMO_CIR.H{cont};
end

%% New Structure MIMO

Beam_MIMO=struct;

Beam_MIMO.ReceiveAntennas=NumClusters;
Beam_MIMO.TransmitAntennas=NumClusters;
Beam_MIMO.Index=MIMO_CIR.Index;
Beam_MIMO.Time=MIMO_CIR.Time;
Beam_MIMO.AOA=MIMO_CIR.AOA;
Beam_MIMO.AOD=MIMO_CIR.AOD;

% Beam_MIMO.H=cell(1,length(Beam_MIMO.Index));
Beam_MIMO.H=cellfun(@(x) BeamformingMatrix.AOA*x*BeamformingMatrix.AOD,MIMO_CIR.H,'UniformOutput',0);
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









