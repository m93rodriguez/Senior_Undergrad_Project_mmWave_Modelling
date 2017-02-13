%% Initialize

Input_Parameters
addpath functions
addpath Scripts

CIR=System_Generation(Param);
MIMO_CIR=CIR.MIMO;
Statistics_MIMO=Extract_MIMO_Statistics(MIMO_CIR);

%% Beamforming Paramteres

MaxAntennas=MIMO_CIR.TransmitAntennas;
NumClusters=4;
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
    BeamformingMatrix.AOD((cont-1)*AntennasPerCluster+1:AntennasPerCluster*cont,...
        cont)=(0:AntennasPerCluster-1)'*pi*sin(ClusterAngle.AOD(cont));
    
end
BeamformingMatrix.AOD=exp(1i*BeamformingMatrix.AOD);

%% Arrival matrix

BeamformingMatrix.AOA=zeros(MaxAntennas,NumClusters);

for cont=1:NumClusters
    BeamformingMatrix.AOA((cont-1)*AntennasPerCluster+1:AntennasPerCluster*cont,...
        cont)=(0:AntennasPerCluster-1)'*pi*sin(ClusterAngle.AOA(cont));
    
end
BeamformingMatrix.AOA=exp(1i*BeamformingMatrix.AOA).';

%%
A=zeros(length(NumClusters));
H=zeros(16);
for cont=1:length(MIMO_CIR.Index)
    A=A+BeamformingMatrix.AOA*MIMO_CIR.H{cont}*BeamformingMatrix.AOD;
    H=H+MIMO_CIR.H{cont};
end


