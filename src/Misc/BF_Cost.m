
NumClusters=1;
 Threshold=0.3; NumPoints=1000; CostExponents=[1 0];

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



clf
subplot(2,2,[2,4])
imagesc(Theta*180/pi,Theta*180/pi,CostRatio),colormap jet, colorbar
subplot(2,2,1)
Plot_polar_dB(AOD,AngPDP/max(AngPDP),20,'.')
subplot(2,2,3)
Plot_polar_dB(AOA,AngPDP/max(AngPDP),20,'.')
