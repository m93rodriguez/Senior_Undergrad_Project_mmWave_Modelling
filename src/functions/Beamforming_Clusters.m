function Clusters=Beamforming_Clusters(MIMO_CIR, NumClusters,...
    CostExponents,Threshold,NumPoints)
%Beamforming clusters generation
%
% Clusters=Beamforming_Clusters(MIMO_CIR,NumClusters). MIMO_CIR is a MIMO
% Channel Impulse Response as generate by the function System_Generation.
% NumClusters is the number of beamforming pointing directions. The number
% of antennas in MIMO_CIR divided by NumClusters must be an integer number.
% Clusters is a struct variable that contains the AOD (Angle of Departure)
% and AOA (Angle of Arrival) angles for each cluster, and the corresponding
% Departure and Arrival beamforming matrices. 
%
% Clusters=Beamforming_Clusters(...,CostExponents) allows to specify the
% weights used for the generation of the cost function. It must be a vecotr
% of size [1 2], where the first element correspond to the weight of the
% Power component, and the second element corresponds to the Delay Spread
% component. The default value is [1 0.5].
%
% Clusters=Beamforming_Clusters(...,Threshold) allows to specify the
% maximum peak value that is used to define the clusters from the cost
% function, as a percentage of the maximum value. The default value es 0.3.
%
% Clusters=Beamforming_Clusters(...,NumPoints) allows to specify the angle
% resolution used to specify the cost function domain. The angle mesh is
% obtained by a linear spacing form -pi/2 to pi/2 using NumPoints
% divisions. The default value is 1000;

% Input default Anguments--------------------------------------------------
if nargin==4, Threshold=0.3; end
if nargin==3, Threshold=0.3; NumPoints=1000; end
if nargin==2, Threshold=0.3; NumPoints=1000; CostExponents=[1 0.5]; end

% Functions----------------------------------------------------------------
GetPower=@(x) sum(x(:));
U=@(x,x0,N) psinc(pi*(sin(x)-sin(x0)),N).^2/N;

% Parameters---------------------------------------------------------------
MaxAntennas=min(MIMO_CIR.TransmitAntennas,MIMO_CIR.ReceiveAntennas);
AntennasPerCluster=round(MaxAntennas./NumClusters);

% Insufficient antennas control
if AntennasPerCluster<=1
    Clusters.AOD=zeros(1,MaxAntennas);
    Clusters.AOA=zeros(1,MaxAntennas);
    Clusters.BeamformingMatrixAOD=eye(MaxAntennas);
    Clusters.BeamformingMatrixAOA=eye(MaxAntennas);
    Clusters.PhysicalClusters=0;
    return
end

% Channel Characteristics--------------------------------------------------
AngPDP=MIMO_CIR.PDP;
AngPDP=cellfun(GetPower,AngPDP);
Time=MIMO_CIR.Time;
AOD=MIMO_CIR.AOD;
AOA=MIMO_CIR.AOA;

% Angular Discretization---------------------------------------------------
Theta=linspace(-pi/2,pi/2,NumPoints);

% Cost Function------------------------------------------------------------
PowerAOD=cell(1,length(AOD));
PowerAOA=cell(1,length(AOD));
MatrixPower=cell(1,length(AOD));
TotalPower=zeros(length(Theta));
for cont=1:length(AOD)
    
    PowerAOD{cont}=U(Theta,AOD(cont),AntennasPerCluster)*AngPDP(cont);
    PowerAOA{cont}=U(Theta,AOA(cont),AntennasPerCluster)*AngPDP(cont);
    
    [PowerAOD{cont},PowerAOA{cont}]=meshgrid(PowerAOD{cont},PowerAOA{cont});
    
    MatrixPower{cont}=PowerAOD{cont}.*PowerAOA{cont};
    TotalPower=TotalPower+MatrixPower{cont};
end

MeanTime=zeros(length(Theta));

for cont=1:length(Time)
    MeanTime=MeanTime+MatrixPower{cont}*Time(cont);
end
MeanTime=MeanTime./TotalPower;
RMSTime=zeros(length(Theta));
for cont=1:length(Time)
    RMSTime=RMSTime+(MeanTime-Time(cont)).^2.*MatrixPower{cont};
end
RMSTime=sqrt(RMSTime./TotalPower);

CostFunction=(TotalPower./max(TotalPower(:))).^CostExponents(1)./...
    (RMSTime/max(RMSTime(:))).^CostExponents(2);

% Locate Maxima -----------------------------------------------------------
CostRatio=CostFunction/max(CostFunction(:));

[GradX,GradY]=gradient(CostFunction);
DGradX=diff(GradX')';
DGradY=diff(GradY);

SignX=GradX(:,2:end).*GradX(:,1:end-1);
SignY=GradY(2:end,:).*GradY(1:end-1,:);
SignX=SignX<=0;
SignY=SignY<=0;

MaxX=SignX.*(DGradX<0);
MaxY=SignY.*(DGradY<0);

Max=MaxX(2:end,:).*MaxY(:,2:end);
Max=Max.*(CostRatio(2:end,2:end)>Threshold);

% Physical clusters--------------------------------------------------------
[PosY,PosX]=ind2sub(size(Max),find(Max));
PosX=PosX+1;
PosY=PosY+1;

Cost=zeros(size(PosX));
AODMax=Cost;
AOAMax=Cost;

for cont=1:length(PosX)
    Cost(cont)=CostFunction(PosY(cont),PosX(cont));
    AODMax(cont)=Theta(PosX(cont));
    AOAMax(cont)=Theta(PosY(cont));
    
end

[~,Ind]=sort(Cost,'descend');
AODMax=AODMax(Ind)';
AOAMax=AOAMax(Ind)';

PhyClusters=length(Cost);

% Generate Clusters-------------------------------------------------------

ClusterInd=1:NumClusters;
while sum(ClusterInd>PhyClusters)>0
    ClusterInd(ClusterInd>PhyClusters)=ClusterInd(ClusterInd...
        >PhyClusters)-PhyClusters;
end

Clusters.AOD=AODMax(ClusterInd);
Clusters.AOA=AOAMax(ClusterInd);

% Departure Matrix---------------------------------------------------------
AODMatrix=zeros(MaxAntennas,NumClusters);
for cont=1:NumClusters
    Shift=exp(1i*(0:AntennasPerCluster-1)'*pi*sin(Clusters.AOD(cont)));
    AODMatrix(AntennasPerCluster*(cont-1)+1:AntennasPerCluster*cont,cont)=Shift;
end
% Arrival Matrix-----------------------------------------------------------
AOAMatrix=zeros(MaxAntennas,NumClusters);
for cont=1:NumClusters
    Shift=exp(-1i*(0:AntennasPerCluster-1)'*pi*sin(Clusters.AOA(cont)));
    AOAMatrix(AntennasPerCluster*(cont-1)+1:AntennasPerCluster*cont,cont)=Shift;
end
AOAMatrix=AOAMatrix.';

% Output
Clusters.BeamformingMatrixAOD=AODMatrix;
Clusters.BeamformingMatrixAOA=AOAMatrix;
Clusters.PhysicalClusters=PhyClusters;
end % End of Function