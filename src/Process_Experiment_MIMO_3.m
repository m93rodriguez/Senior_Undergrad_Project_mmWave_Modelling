if ~exist('SpatialStatistics','var')
    load Results_Experiment_MIMO_3_ALL.mat
end
%%
addpath Simulation_Results
addpath functions
clearvars -except GainVector TimeStatistics ErrorStatistics SpatialStatistics
%% Experiment Conditions

SymbolDuration=[20 27 40 60 100 160 200];
SymbolDuration_ns=[50 67.5 100 150 250 400 500];
SymbolDuration_MHz=[20 15 10 6.7 4 2.5 2];
ModulationOrder=[1,2,4,6,8];

SNR_Range=[Inf 5 7 10 20 50 70 100];

NumClusters=[16 8 4 2 1];


Color={[0 0.4470 0.7410],[0.8500    0.3250    0.0980],[0.9290    0.6940    0.1250] ,...
    [0.4940    0.1840    0.5560],[0.4660    0.6740    0.1880],[0.3010    0.7450    0.9330],...
    [0.6350    0.0780    0.1840]};
%% Gain

% Gain Distribution
Fig_Cluster_Power_Ratio=figure(1);
Fig_Cluster_Power_Ratio.Position=[884 337 998 623];
clf
% Analysis 1 ---------------------------------------------------
Mu={};
Sigma={};
RMS={};
RelativeGain=cell(1,5);
for Cluster=1:5;
Gain=GainVector{Cluster}.^2;
for cont=1:NumClusters(Cluster)
    [CData,xdata]=histcounts(Gain(cont,:),20,'Normalization','cdf');
    xdata=xdata(2:end);
%     plot(xdata,CData,'.-')
    hold on
    % Rayleigh
    b=raylfit(Gain(cont,:));
%     plot(xdata,raylcdf(xdata,b));
    RMS{Cluster}(cont,1)=rms(CData-raylcdf(xdata,b));
    %Log Normal
    [mu,sigma]=normfit(10*log10(Gain(cont,:)));
    Mu{Cluster}(cont)=mu;
    Sigma{Cluster}(cont)=sigma;
%     plot(xdata,normcdf((10*log10(xdata)-mu)/sigma))
    RMS{Cluster}(cont,2)=rms(CData-normcdf((10*log10(xdata)-mu)/sigma));
    %Exponential
    mu=expfit(Gain(cont,:));
%     plot(xdata,expcdf(xdata,mu))
    RMS{Cluster}(cont,3)=rms(CData-expcdf(xdata,mu));
%     pause(0.1)
end

RelativeGain{Cluster}=Gain';
RelativeGain{Cluster}=RelativeGain{Cluster}./(RelativeGain{Cluster}(:,1)*ones(1,NumClusters(Cluster)));
RelativeGain{Cluster}=RelativeGain{Cluster}./(sum(RelativeGain{Cluster},2)*ones(1,NumClusters(Cluster)));
RelativeGain{Cluster}=median(RelativeGain{Cluster},1);
RelativeGain{Cluster}=[RelativeGain{Cluster} zeros(1,16-length(RelativeGain{Cluster}))];
end

RelativeGain=cat(1,RelativeGain{:});
RelativeGain=flip(RelativeGain(1:5,1:5));
bar(RelativeGain')
set(gca,'FontSize',13)
title('\textbf{Beamforming Cluster Power Ratio}','Interpreter','latex','FontSize',20)
xlabel('Independent Channel Index','Interpreter','latex','FontSize',18)
ylabel('Power Ratio','Interpreter','latex','FontSize',18)
L=legend('16','8','4','2','1');
L.Title.String='\textbf{Antenas per Cluster}';
L.FontSize=15;
L.Interpreter='latex';
A=gca;
A.XTick=[1 2 3 4 5];
grid on
% Este analysis es para mostrar cual de las distribuciones entre la de
% Rayleigh, LogNormal y Exponencial se ajusta mejor a los datos de potencia
% de cada una de las antenas en cada cluster. Da los resultados de
% parametros de la Lognormal para cada caso y el error RMS de las
% distribuciones. Se muestra que la que mas se acerca es la Lognormal
%----------------------------------------------------------------------

% Analysis 2
% Se quiere ver los resultados de potencia total. Ver si la distribucion
% sigue una lognormal (no se espera esto, ya que una suma de lognormales no
% genera una lognormal), y obtener la eficiencia de las ganancias de
% beamforming
TotalPower=cellfun(@(x) sum(x.^2,1),GainVector,'UniformOutput',0);
TotalPower=cat(1,TotalPower{:})';

Mu_Power=zeros(1,5);
Sigma_Power=zeros(1,5);
for cont=1:5
    P=TotalPower(:,cont);
    [CData,xdata]=histcounts(10*log10(P),20,'Normalization','cdf');
    xdata=xdata(2:end);
    
    [mu,sigma]=normfit(10*log10(P));
    Mu_Power(cont)=mu;
    Sigma_Power(cont)=sigma;
    
%     plot(xdata,CData,'.')
%     hold on
%     plot(xdata,normcdf(xdata,mu,sigma))
%     pause(2)
%     hold off
end

TotalPowerApprox=cellfun(@(x) sum(10.^(x/10)),Mu);

% Efficiency
Power=TotalPower./16^2; % Total emitted power is 1
Efficiency=Power./(ones(250,1)*([1 2 4 8 16].^2));
Efficiency=Efficiency./(Efficiency(:,1)*ones(1,5));

Mu_Eff=Mu_Power-20*log10(flip(NumClusters))-Mu_Power(1);
Sigma_Eff=Sigma_Power-Sigma_Power(1);

% Probability Under single antennas

Mu_Ratio=Mu_Power-Mu_Power(1);
Sigma_Ratio=Sigma_Power-Sigma_Power(1);
x=0.5:0.01:256;
for cont=1:length(x)
Probability(cont,:)=normcdf(10*log10(x(cont)),Mu_Ratio,Sigma_Ratio);
end


Fig_Power_Ratio=figure(2);
Fig_Power_Ratio.Position=[884 337 998 623];
clf
semilogx(x,Probability(:,2:end),'LineWidth',1.5)
axis([0.5 260 0 1])
hold on
plot([1 1],[0 1],'--k','LineWidth',1)
plot(4*ones(1,2),[0 1],'--k','LineWidth',1)
plot([16 16],[0 1],'--k','LineWidth',1)
plot([64 64],[0 1],'--k','LineWidth',1)
plot([256 256],[0 1],'--k','LineWidth',1)
set(gca,'FontSize',13)
hold off
title('\textbf{Relative Power - Beamforming Gain}','Interpreter','latex','FontSize',20)
xlabel('Beamforming Gain - $G_{BF}^{(N)}$','Interpreter','latex','FontSize',18)
ylabel('Cumulative Probaility','Interpreter','latex','FontSize',18)
L=legend('2','4','8','16','Location','best');
L.Title.String='\textbf{Antenas per cluster}';
L.FontSize=15;
L.Interpreter='latex';

A=gca;
A.XTick=[1 4 16 64 256];
grid on
A.XMinorGrid='off';


%% Time Dispersion

TimeRMS=cellfun(@(x) x.MeanRMS,TimeStatistics);
Fig_Time=figure(3);
Fig_Time.Position=[884 337 998 623];
clf
L={};
AntennasPerCluster=[1 2 4 8 16];
for Cluster=1:5
    
    [CData,xdata]=histcounts(TimeRMS(:,Cluster),0:10/4:60,'Normalization','cdf');
    xdata=xdata(2:end);
    plot(xdata,CData,'.--','LineWidth',1.5,'MarkerSize',15)
    hold on
    L=[L {num2str(AntennasPerCluster(Cluster))}];
    TimeCluster{Cluster}=CData;
end

SISO_Time=[0.0152,    0.0758,    0.2172,    0.3081,    0.3384,    0.3384,...
    0.3636,    0.4293,    0.5000,    0.5000,    0.5354,    0.5859,...
    0.6364,    0.6970,    0.7374,    0.8182,    0.8889,    0.8990,...
    0.9293,    0.9495,    0.9596,    0.9798,    0.9798,    1.0000];

plot(xdata,SISO_Time,'k.--','LineWidth',1.5,'MarkerSize',15)

L=legend([L,{'SISO'}],'Location','best');
L.Title.String='\textbf{Antennas per Cluster}';
L.FontSize=15;
L.Interpreter='latex';
set(gca,'FontSize',13)
grid on
title('\textbf{RMS Delay Spread CDF}','Interpreter','latex','FontSize',20)
xlabel('RMS Delay Spread (ns)','Interpreter','latex','FontSize',18)
ylabel('Cumulative Probability','Interpreter','latex','FontSize',18)

%% Interference Noise

% Color={'b','r','y','m','g','k','c'};

Resta=[15 7 3 1 0];

Fig_Interference=figure(4);
Fig_Interference.Position=[884 337 998 623];
clf
Linea=[];
% for Cluster=1:5
Mu_ISI_Cluster=cell(5,7);
for    Cluster=1:1
    for Order=1:5
        for BW=1:7;
            
            Modulation=Define_Modulation(1,1,1,ModulationOrder(Order),'QAM','on');
            Energy=Modulation.ConstellationEnergy;
            
            Noise=arrayfun(@(x) ErrorStatistics{x,Cluster,Order}{BW}...
                {1}.Interference,1:250,'UniformOutput',0);
            Noise=cellfun(@(x) permute(x,[3,1,2]),Noise,'UniformOutput',0);
            Noise=cat(1,Noise{:});
            
            Noise=Noise(:,:,3);
            Gain=GainVector{Cluster}';
            
            Noise=(Noise).*(Gain.^1)/(Energy);
            AllNoise{Cluster,BW}=Noise;
            NoiseLog=10*log10(Noise);
            
            % clf
            AuxISI=zeros(1,16);
            for cont=1:min(6,NumClusters(Cluster))
                AuxLog=NoiseLog(:,cont);
                [CData,xdata]=histcounts(AuxLog,20,'Normalization','cdf');
                xdata=xdata(2:end);
                [mu,sigma]=normfit(AuxLog);
                %             plot(xdata,CData,[Color{BW},'.'])
                hold on
                Linea(BW)=plot(xdata,(normcdf(xdata,mu,sigma)),'Color',Color{BW},'LineWidth',1.5);
                %     hold off
%                     pause(1)
                AuxISI(cont)=mu;
               
            end
             Mu_ISI_Cluster{Cluster,BW}=AuxISI;
        end
    end
   
end
L=legend(Linea,'20 MHz','15 MHz','10 MHz','6.7 MHz','4 MHz','2.5 MHz',...
    '2 MHz','Location','southeast');
L.Title.String='\textbf{Bandwidth}';
L.FontSize=15;
L.Interpreter='latex';
grid
set(gca,'FontSize',13)
title(['\textbf{Interference Noise CDF - ',num2str(NumClusters(Cluster)),' Channels}'],'Interpreter','latex','FontSize',20)
xlabel('Noise Density - $\mathcal{D}_i$ (dB)','Interpreter','latex','FontSize',18)
ylabel('Cumulative Probability','Interpreter','latex','FontSize',18)

%% Interference Noise vs Cluster
% Color={'b','r','y','m','g','k','c'};
Order=3;
for Cluster=1:5
    for BW=1:7
        Modulation=Define_Modulation(1,1,1,ModulationOrder(Order),'QAM','on');
        Energy=Modulation.ConstellationEnergy;
        Noise=arrayfun(@(x) ErrorStatistics{x,Cluster,Order}{BW}...
            {1}.Interference,1:250,'UniformOutput',0);
        Noise=cellfun(@(x) permute(x,[3,1,2]),Noise,'UniformOutput',0);
        Noise=cat(1,Noise{:});
        Noise=Noise(:,:,3);
        Gain=GainVector{Cluster}';
        Noise=Noise.*(Gain.^1)/Energy;
        AllNoise{Cluster,BW}=Noise;%/NumClusters(Cluster);
    end
end

Fig_Interference_Cluster=figure(5);
Fig_Interference_Cluster.Position=[884 337 998 623];
clf
ClusterNoise=cellfun(@(x) sum(x,2)/size(x,2),AllNoise,'UniformOutput',0);
% ClusterNoise=cellfun(@(x) x(:,min(16,size(x,2))),AllNoise,'UniformOutput',0);
TimeRMS=cellfun(@(x) x.MeanRMS,TimeStatistics);

BW=3;
L={'16','8','4','2','1'};
clear P
for BW=1:7
for Cluster=1:5
    Noise=10*log10(ClusterNoise{Cluster,BW});
    [CData,xdata]=histcounts(Noise,20,'Normalization','cdf');
    xdata=xdata(2:end);
    
    [mu,sigma]=normfit(Noise);
    Mu_ISI(Cluster,BW)=mu;
    Sigma_ISI(Cluster,BW)=sigma;
%     P(BW)=plot(xdata,normcdf(xdata,mu,sigma),'LineWidth',1.5,'Color',Color{BW});
%     hold on
%     plot(xdata,CData,'.','Color',Color{BW})
%     pause(0.1)
    
end

% hold off
end
% L=legend(P,'20 MHz','15 MHz','10 MHz','6.7 MHz','4 MHz','2.5 MHz',...
%     '2 MHz','Location','best');
% L.Title.String='Bandwidth';
% title('Interference Noise CDF - Beamforming Clusters')
% xlabel('Noise Power (dBm)')
% ylabel('Cumulative Probability')

bar(Mu_ISI')
grid on
A=gca;
A.FontSize=13;
A.XTickLabel={'20 MHz','15 MHz','10 MHz','6.7 MHz','4 MHz','2.5 MHz','2 MHz'};
xlabel('Bandwidth','Interpreter','latex','FontSize',18)
ylabel('Mean Noise Density - $\mathcal D_i$ (dB)','Interpreter','latex','FontSize',18)
title('\textbf{Interference Noise - Beamforming Clusters}','Interpreter','latex','FontSize',20)
L=legend({'1','2','4','8','16'},'Location','best');
L.Title.String='\textbf{Antennas per Cluster}';
L.FontSize=15;
L.Interpreter='latex';

%% Spatial
M=[];

for Cluster=2:5;
    [CData,xdata]=histcounts(SpatialStatistics(:,Cluster),0.5:6.5);
    M=[M;CData];
end
Fig_Spatial=figure(6);
Fig_Spatial.Position=[884 337 998 623];
bar(M'/250)
set(gca,'FontSize',13)
title('\textbf{Beamforming Spatial Lobes}','Interpreter','latex','FontSize',20)
xlabel('Number of lobes detected','Interpreter','latex','FontSize',18)
ylabel('Count ratio','Interpreter','latex','FontSize',18)

L=legend('2','4','8','16','Location','best');
L.Title.String='\textbf{Antenas per Cluster}';
L.FontSize=15;
L.Interpreter='latex';
% Correlation with Time
grid on
for Cluster=2:5
    R_Spatial(Cluster-1)=corr2(TimeRMS(:,Cluster),SpatialStatistics(:,Cluster));
end

%% Error

% Color={'b','r','c','m','g','y','k'};
Fig_Error=figure(7);
Fig_Error.Position=[884 337 998 623];
clf
for Cluster=1:5
    for Order=1:5;
        for BW=1:7;
            
            
            % Get Noise Energy
            
            % Interference Noise
            Modulation=Define_Modulation(1,1,1,ModulationOrder(Order),'QAM','on');
            Energy=Modulation.ConstellationEnergy;
            Noise=arrayfun(@(x) ErrorStatistics{x,Cluster,Order}{BW}...
                {1}.Interference,1:250,'UniformOutput',0);
            Noise=cellfun(@(x) permute(x,[3,1,2]),Noise,'UniformOutput',0);
            Noise=cat(1,Noise{:});
            
            if Order==1; Noise=Noise(:,:,1); else
            Noise=Noise(:,:,3)/2; end
            
            Gain=GainVector{Cluster}';
            Noise=Noise.*(Gain.^2)/Energy;
            Noise=Noise*SymbolDuration(BW);
            
            % Total Noise
            TotalSNR=[];
            SNR_Vector=1:8;
            for SNR=SNR_Vector
                % AWGN
                NoiseDensity=mean(Gain.^2,2).*SymbolDuration(BW)/SNR_Range(SNR);
                NoiseDensity=NoiseDensity*ones(1,NumClusters(Cluster));
                
                % Total Noise
                TotalNoise=1*Noise+NoiseDensity;
                TotalSNR(:,1:NumClusters(Cluster),SNR)=Gain.^2*SymbolDuration(BW)^1./TotalNoise;
            end
            
            BitError=[];
            for cont=1:250
                for SNR=SNR_Vector
                    ErrorStruct=ErrorStatistics{cont,Cluster,Order}{BW}{SNR};
                    BitError(cont,1:NumClusters(Cluster),SNR)=ErrorStruct.BitError;
                end
            end
            
            
            % plot(10*log10(TotalSNR(:)),10*log10(BitError(:)),[Color{Order},'.'],'MarkerSize',15)
            S(Order)=scatter(10*log10(TotalSNR(:)),10*log10(BitError(:)),10,Color{Order},'filled');
            hold on
            
        end
    end
end
set(gca,'FontSize',13)
L=legend(S,'1','2','4','6','8');
L.Title.String='\textbf{Bits per Symbol}';
L.FontSize=15;
L.Interpreter='latex';
axis([-10 40 -20 0])
% Theoretical Error
x=linspace(10^0.3,10^0.9,5000);
y=2*qfunc(sqrt(x));
plot(10*log10(x),10*log10(y),'--k','LineWidth',2)

MinX=[10^.56 10 10^1.4 10^1.7];
MaxX=[10^1.2 10^1.8 10^2.4 10^2.9];
for cont=2:5
    b=[1,2,4,6,8];
    M=2.^b(cont);
    N=4*(sqrt(M)-2)^2+3*4*(sqrt(M)-2)+4*2;
    N=N/M;
    Modulation=Define_Modulation(1,1,1,b(cont),'QAM','on');
    x=linspace(MinX(cont-1),MaxX(cont-1),5000);
    y=N*qfunc(Modulation.MinDistance.*sqrt(x)/2)/(b(cont)-1);
    plot(10*log10(x),10*log10(y),'--k','LineWidth',2);
end

title('\textbf{Probability of Error}','Interpreter','latex','FontSize',20)
xlabel('SINR (dB)','Interpreter','latex','FontSize',18)
ylabel('Probability of Error (dB)','Interpreter','latex','FontSize',18)
grid on














