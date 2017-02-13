function [ClusterAngles,ClusterCost]=Beamforming_Clusters(MIMO_CIR,Statistics_MIMO,N_Antennas)

% Functions
GetPower=@(x) sum(x(:));
U=@(x,x0,N) psinc(pi*(sin(x)-sin(x0)),N).^2/N;

% Channel characteristics
%-------------------------------------
AngPDP=MIMO_CIR.PDP;
AngPDP=cellfun(GetPower,AngPDP);
TotalPower=sum(AngPDP);

Time=MIMO_CIR.Time;
RMS=Statistics_MIMO.RMSDelaySpread;

AOD=MIMO_CIR.AOD;
AOA=MIMO_CIR.AOA;
%------------------------------------
% Angular discretization
Theta=linspace(-pi/2,pi/2,1000);
%------------------------------------
DirectionString={'AOD','AOA'};
for cont_Dir=[1,2];
    Direction=eval(DirectionString{cont_Dir});
    ArrayPower=zeros(length(Direction),length(Theta));

    for cont=1:length(Direction)
        ArrayPower(cont,:)=U(Theta,Direction(cont),N_Antennas)*AngPDP(cont);
    end
    MeanTime=ArrayPower'*Time';
    MeanTime=MeanTime'./sum(ArrayPower);
    RMSTime=Time'*ones(size(Theta))-ones(size(Time'))*MeanTime;
    RMSTime=sum((RMSTime.^2.*ArrayPower))./(sum(ArrayPower));
    RMSTime=sqrt(RMSTime);
    
    ArrayPower=sum(ArrayPower);
    
    CostExponent=[1.5 1];
    % Note: This exponents control de behaviour of the cost function. The first
    % exponent indicates the weight of the power component and the second
    % indicates the weight of the Delay Spread component. It if prefered that
    % the power component has a higher weight. However, if the power weight is
    % too high, the number of usable peaks will be less. If the proportion of
    % the exponents is kept constant, but both are changed by the same factor,
    % the sharpness/smoothness of the cost function is varied, giving (or
    % taking away) importance to the main peaks.
    CostFunction=(ArrayPower/TotalPower).^CostExponent(1);
    CostFunction=CostFunction./((RMSTime/RMS).^CostExponent(2));
    
    % Find maxima --------------------------------------
    CostRatio=CostFunction/max(CostFunction);
    Diff1=diff(CostRatio);
    Diff2=diff(Diff1);

    Sign1=Diff1(2:end).*Diff1(1:end-1);
    Sign1=Sign1<=0;

    Sign2=Diff2<0;

    Maxima=logical(Sign1.*Sign2);

    MaximaPos=find(Maxima)+1;

    Threshold=0.1;
    % This parameter determines the minimum level (relative to the highest) of
    % the peaks of the Cost Function that are taken into account for the
    % working points;

    % if Sign2(1); MaximaPos=[1 MaximaPos]; end7
    % if Sign2(end); MaximaPos=[MaximaPos length(CostRatio)]; end

    MaximaPos=MaximaPos(CostRatio(MaximaPos)>Threshold);
    MaximaAngle=Theta(MaximaPos);
    %---------------------------------------------------
    
    % Output Variable -------------------------------
    Cost=CostFunction(MaximaPos);
    [Cost,Index]=sort(Cost,'descend');
    MaximaAngle=MaximaAngle(Index);
    ClusterAngles.(DirectionString{cont_Dir})=MaximaAngle;
    ClusterCost.(DirectionString{cont_Dir})=Cost;
    
    %------------------------------------------------
end % End of DirectionString

end % End of Function