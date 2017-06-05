%% Process Experiment MIMO (ALL) Results

% Variable Structure:
% Resultados_MIMO - 5D cell
% - 1: Antenna Separation 1:2:10 (half lambda) (5)
% - 2: CIR count (30)
% - 3: Number of Antennas 1:2:16 (8)
% - 4: Modulation Order (3)
% - 5: Narrowband Factor 10:20:100 (5)

% Each position is a structure with fields:
% - GainVector: Size 1 x Number of Antennas
% - Interference Noise: cell Number of Antennas x 3
%   - Each row is an Antenna
%   - Column 1: Dispersion of demodulated points
%   - Column 2: In-Phase Null-Hypothesis and p-value
%   - Column 3: Quadrature Null-Hypothesis and p-value

%% Set up Intervals

Separation=1:2:10; % Units: lambda/2
CIR=1:30;
Antennas=1:2:16;
ModulationOrder=1:3;
Narrowband=10:20:100;

%% Gaussianity Test

Distance=1; % Max 5
AntennaCluster=8; %Max 8

Prob_real=zeros(2*AntennaCluster-1,30,5);
Prob_imag=Prob_real;
for Order=1:3
for cont_CIR=CIR
    for cont_Antenna=1:2*AntennaCluster-1
        for cont_Factor=1:5
        Prob_real(cont_Antenna,cont_CIR,cont_Factor)=Resultados_MIMO{Distance,...
            cont_CIR,AntennaCluster,Order,cont_Factor}.InterferenceNoise{cont_Antenna,2}(1);
        Prob_imag(cont_Antenna,cont_CIR,cont_Factor)=Resultados_MIMO{Distance,...
            cont_CIR,AntennaCluster,Order,cont_Factor}.InterferenceNoise{cont_Antenna,3}(1);
        end
    end
end

Prob_real=mean(Prob_real,2);
Prob_real=permute(Prob_real,[1,3,2]);
Prob_imag=permute(mean(Prob_imag,2),[1,3,2]);

subplot(3,2,2*Order-1)
plot(Prob_real),title(['In-Phase Gaussianity, Order ',num2str(Order),...
    ' Antennas in Cluster: ',num2str(AntennaCluster*2-1)])
axis([1 2*AntennaCluster-1,0,01])
xlabel('Antenna ID'),ylabel('Probability of not Gaussian')
subplot(3,2,2*Order)
plot(Prob_imag),title(['Quadrature Gaussianity, Order ',num2str(Order)])
axis([1 2*AntennaCluster-1,0,01])
xlabel('Antenna ID'),ylabel('Probability of not Gaussian')

end

%% Noise Measurement

Distance=1; % Max 5
AntennaCluster=8; % Max 8
Order=3;
Factor=5;

NoisePower=zeros(AntennaCluster*2-1,30);
Gain=NoisePower;

for cont_Antenna=1:AntennaCluster*2-1
    for cont_CIR=CIR
        Points=Resultados_MIMO{Distance,cont_CIR,...
            AntennaCluster,Order,Factor}.InterferenceNoise{cont_Antenna,1};
        NoisePower(cont_Antenna,cont_CIR)=var(Points);
        
        Gain(:,cont_CIR)=Resultados_MIMO{Distance,cont_CIR,...
            AntennaCluster,Order,Factor}.GainVector;
        
    end
end

AbsoluteNoise=Gain.^2.*NoisePower;
MeanNoise=median(AbsoluteNoise(:));
figure
subplot(2,1,1)
scatter(Gain(:),AbsoluteNoise(:))
title('Channel Gain vs Interference Noise Scatter Plot')
xlabel('Channel Gain'),ylabel('Interference Noise Power')
subplot(2,1,2)
histogram(AbsoluteNoise(:),40,'Normalization','pdf')
title('Interference Noise Probability Density Function')
xlabel('Interference Noise Power')
ylabel('Probability Density')

%% Noise Characterization

Order=3;
for cont_Factor=1:5
    for cont_Cluster=1:8
        for cont_Distance=1:5
            %----
            NoisePower=zeros(cont_Cluster*2-1,30);
            Gain=NoisePower;
            for cont_Antenna=1:cont_Cluster*2-1
                for cont_CIR=CIR
                    Points=Resultados_MIMO{cont_Distance,cont_CIR,...
                        cont_Cluster,Order,cont_Factor}.InterferenceNoise{cont_Antenna,1};
                    NoisePower(cont_Antenna,cont_CIR)=var(Points);
                    
                    Gain(:,cont_CIR)=Resultados_MIMO{cont_Distance,cont_CIR,...
                        cont_Cluster,Order,cont_Factor}.GainVector;
                end
            end
            NoisePower=Gain.^2.*NoisePower;
            NoisePower=median(NoisePower(:));
            %----
            
            SystemNoise(cont_Cluster,cont_Distance,cont_Factor)=NoisePower;
            
        end
    end
end
SystemNoise=permute(SystemNoise,[1,3,2]); %Antennas 8 ,Factor 5 ,Distance 5
SystemNoise=mean(SystemNoise,3);

for i=1:5
    
    m(i)=mean(diff(SystemNoise(:,i)))/2;
    
end
figure
plot(10:20:100,m,'*')
Fit=fit((10:20:100)',m','power1');
a=Fit.a;
b=Fit.b;
hold on
plot(10:1:90,a*(10:1:90).^b)

xlabel('Narrowband Factor')
ylabel('Number of Antennas Slope')
title('Interference Noise Characterization')

%% Gain

cont_Distance=1;

Order=1;
cont_Factor=5;
figure
hold on
for cont_Cluster=1:8;
    Gain=zeros(cont_Cluster*2-1,30);
    for cont_Antenna=1:cont_Cluster*2-1
        for cont_CIR=CIR
            Gain(:,cont_CIR)=Resultados_MIMO{cont_Distance,cont_CIR,...
                cont_Cluster,Order,cont_Factor}.GainVector;
        end
    end
    Gain=mean(Gain,2);
    plot(1:cont_Cluster*2-1,Gain.^2/(cont_Cluster*2-1),'*-')
    
    L{cont_Cluster}=num2str(cont_Cluster*2-1);
end
title('System Antenna Gain - Number of Antennas in Cluster')
xlabel('Antenna ID')
ylabel('Antenna Gain')
L1=legend(L);



figure
L={};
cont_Cluster=8;
for cont_Distance=1:5;
    Gain=zeros(cont_Cluster*2-1,30);
    for cont_Antenna=1:cont_Cluster*2-1
        for cont_CIR=CIR
            Gain(:,cont_CIR)=Resultados_MIMO{cont_Distance,cont_CIR,...
                cont_Cluster,Order,cont_Factor}.GainVector;
        end
    end
    Gain=mean(Gain,2);
%     plot(Gain.^2/(cont_Cluster*2-1),'-*')
    plot(Gain,'-*')
    hold on
    L{cont_Distance}=[num2str(cont_Distance*2-1) '\lambda/2'];
end
title('System Antenna Gain - Antenna Separation Distance')
xlabel('Antenna ID')
ylabel('Antenna Gain')
legend(L)


for cont_Cluster=1:8
    for cont_Distance=1:5
        Gain=zeros(cont_Cluster*2-1,30);
        for cont_Antenna=1:cont_Cluster*2-1
            for cont_CIR=CIR
                Gain(:,cont_CIR)=Resultados_MIMO{cont_Distance,cont_CIR,...
                    cont_Cluster,Order,cont_Factor}.GainVector;
            end
        end
        Gain=mean(Gain,2);
        TotalGain(cont_Cluster,cont_Distance)=mean(Gain);
    end
end
figure
mesh(1:2:10,1:2:16,TotalGain)
title('System Mean Antenna Gain')
xlabel('Separation Distance')
ylabel('Antennas in Cluster')
zlabel('Largest Atenna Gain')

