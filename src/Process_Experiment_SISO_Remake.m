% addpath Simulation_Results
load Results_SISO_Remake_All.mat
clearvars -except GainVector TimeStatistics ErrorStatistics
% close all
addpath functions

SymbolDuration=[20 27 40 60 100 160 200];
SymbolDuration_ns=[50 67.5 100 150 250 400 500];
SymbolDuration_MHz=[20 15 10 6.7 4 2.5 2];
%% Channel Gain Analysis

% Analysis 1 - Get CDf and compare with Rayleigh and Log-Normal CDFs

[CDF_Data,xdata]=histcounts(GainVector,20,'Normalization','cdf');
xdata=xdata(2:end);

CDF_Rayleigh=raylcdf(xdata,mean(GainVector)/sqrt(pi/2));
% CDF_Rayleigh2=raylcdf(xdata,raylfit(GainVector));

mu=log(mean(GainVector)/sqrt(1+var(GainVector)/mean(GainVector)^2));
sigma=sqrt(log(1+var(GainVector)/mean(GainVector)^2));
CDF_Log=normcdf((log(xdata)-mu)/sigma);
% 
% [mu,sigma]=normfit(log(GainVector));
% CDF_Log2=normcdf((log(xdata)-mu)/sigma);

Fig_Gain=figure(1);
Fig_Gain.Position=[884 337 998 623];
clf
hold on
plot(xdata,CDF_Data,'.-','LineWidth',1.5,'MarkerSize',20)
plot(xdata,CDF_Rayleigh,'LineWidth',1.5,'Color','red')
plot(xdata,CDF_Log,'LineWidth',1.5,'Color','black')
set(gca,'FontSize',13)
title('\textbf{Narrowband Channel Gain CDF}','Interpreter','latex','FontSize',20)
xlabel('Channel Gain','Interpreter','latex','FontSize',18)
ylabel('Cumulative Probability','Interpreter','latex','FontSize',18)
grid
L=legend('Obtained Data','Rayleigh CDf','Log-Normal CDF','Location','best');
L.FontSize=15;
L.Interpreter='latex';
RMS_Rayleigh=rms(CDF_Data-CDF_Rayleigh);
RMS_Log=rms(CDF_Data-CDF_Log);

%% Time Dispersion Analysis

TimeRMS=cellfun(@(x) x.MeanRMS,TimeStatistics);
[CDF_Time,xdata]=histcounts(TimeRMS,0:10/4:60,'Normalization','cdf');
xdata=xdata(2:end);

Fig_Time=figure(2);
Fig_Time.Position=[884 337 998 623];
clf
plot(xdata,CDF_Time,'.-','LineWidth',1.5,'MarkerSize',20)
set(gca,'FontSize',13)
title('\textbf{RMS Time Delay CDF}','Interpreter','latex','FontSize',20)
xlabel('RMS Time Delay (ns)','Interpreter','latex','FontSize',18)
ylabel('Cumulative Probability','Interpreter','latex','FontSize',18)
grid

%% ISI Analysis

ModulationType={'PSK','QAM'};
ModulationOrder=[1,2,4,6,8];


Type=1;
Order=5;
BW=1;

Fig_ISI=figure(3);
Fig_ISI.Position=[884 337 998 623];
clf

mu=cell(1,2);
sigma=cell(1,2);

for Type=1:2
    for Order=1:5
%         clf
        for BW=1:7
            
            Modulation=Define_Modulation(1,1,10,ModulationOrder(Order),ModulationType{Type},'on');
            Energy=Modulation.ConstellationEnergy;
            Noise=0;
            Noise=arrayfun(@(x) ErrorStatistics{x,Type,Order}{BW}{1}.Interference,1:200,'UniformOutput',0);
            Noise=cat(1,Noise{:});
            
            Noise=Noise(:,3).*(GainVector').^2;
            Noise=Noise/(Energy);
%             Noise=Noise.*e))
            Noise_log=10*log10(Noise);
            
            [CDF_Log_Noise,xdata]=histcounts(Noise_log,30,'Normalization','cdf');
            xdata=xdata(2:end);
            [mu_aux,sigma_aux]=normfit(Noise_log);
            
            %--------------------------------------------------------------------------
%             plot(xdata,CDF_Log_Noise)
            hold on
            plot(xdata,normcdf(xdata,mu_aux,sigma_aux),'LineWidth',1.5)
            
            % hold off
            % pause(0.5)
            
            %--------------------------------------------------------------------------
            
            error_aux=rms(CDF_Log_Noise-normcdf(xdata,mu_aux,sigma_aux));
            
            error(Order,BW)=error_aux;
            mu{Type}(Order,BW)=mu_aux;
            sigma{Type}(Order,BW)=sigma_aux;
            
            corr_gain(Order,BW)=corr2((GainVector.^1)',Noise);
            corr_time(Order,BW)=corr2(TimeRMS,Noise);
        end
        L=legend('20 MHz','15 MHz','10 MHz','6.7 MHz','4 MHz','2.5 MHz','2 MHz','Location','best');
    end
end
grid
set(gca,'FontSize',13)
title(['\textbf{ISI Noise CDF Approximation}'],'Interpreter','latex','FontSize',20)
xlabel('ISI Noise (dB)','Interpreter','latex','FontSize',18)
ylabel('Cumulative Probability','Interpreter','latex','FontSize',18)
L.FontSize=15;
L.Interpreter='latex';
L.Title.String='\textbf{Bandwidth}';

Fig_Corr=figure(5);
Fig_Corr.Position=[884 337 998 623];

B=bar([mean(corr_time)' mean(corr_gain)']);
A=gca;
A.XTickLabel={'20 MHz','15 MHz','10 MHz','6.7 MHz','4 MHz','2.5 MHz','2 MHz'};
A.FontSize=13;
title('\textbf{Interference Noise Correlation Coefficient}','Interpreter','latex','FontSize',20)
xlabel('Bandwidth','Interpreter','latex','FontSize',18)
ylabel('Correlation Coefficient','Interpreter','latex','FontSize',18)
L=legend('RMS Delay Spread','ChannelGain','Location','northwest');
L.FontSize=15;
L.Interpreter='latex';
grid
colormap summer
%% Error Analysis

SNR_Range=[5 7 10 20 50 70 100];

SymbolDuration=[20 27 40 60 100 160 200];
SymbolDuration_ns=[50 67.5 100 150 250 400 500];
SymbolDuration_MHz=[20 15 10 6.7 4 2.5 2];

% SymbolDuration=[20];
%--------------------------------------------------------
for Type=1:2
    for Order=1:5
        for BW=1:length(SymbolDuration)
            
            Modulation=Define_Modulation(1,1,10,ModulationOrder(Order),ModulationType{Type},'on');
            Energy=Modulation.ConstellationEnergy;
                        
            NoiseAux=arrayfun(@(x) ErrorStatistics{x,Type,Order}{BW}{1}.Interference,1:200,'UniformOutput',0);
            NoiseAux=cat(1,NoiseAux{:});
            NoiseAux=NoiseAux(:,3-Type).*(GainVector').^2/Energy;
            
            NoiseISI(:,Type,Order,BW)=NoiseAux*SymbolDuration(BW); 
        end
    end
end
NoiseDensity=zeros(200,length(SymbolDuration),length(SNR_Range));
for cont=1:length(SNR_Range)
    for BW=1:length(SymbolDuration);
        NoiseDensity(:,BW,cont)=(GainVector').^2*SymbolDuration(BW)/SNR_Range(cont);
    end
end
TotalNoise=zeros(200,2,5,length(SymbolDuration),length(SNR_Range));
TotalSNR=TotalNoise;
for Type=1:2
    for Order=1:5
        for BW=1:length(SymbolDuration)
            for SNR=1:length(SNR_Range)
                TotalNoise(:,Type,Order,BW,SNR)=NoiseDensity(:,BW,SNR)+...
                    NoiseISI(:,Type,Order,BW);
                TotalSNR(:,Type,Order,BW,SNR)=(GainVector').^2*...
                    SymbolDuration(BW)./TotalNoise(:,Type,Order,BW,SNR);
            end
        end
    end
end
%--------------------------------------------------------


clear BitError
clear SymbolError
for cont=1:200
for Type=1:2
    for Order=1:5
        for BW=1:length(SymbolDuration)
            %-----
            % ISI

            
            %------
                       
            for SNR=1:8
                ErrorStruct=ErrorStatistics{cont,Type,Order}{BW}{SNR};
                BitError(cont,Type,Order,BW,SNR)=ErrorStruct.TotalBitError;
                SymbolError(cont,Type,Order,BW,SNR)=ErrorStruct.SymbolError;
            end
        end
    end
end
end

Fig_Error=figure(4);
Fig_Error.Position=[884 0 998 623*2];

clf
for Type=1:2
    subplot(2,1,Type)
% Fig_Error=figure(Type+3);
% Fig_Error.Position=[884 337 998 623];
% clf
hold on
for Order=1:5

ErrorAux=permute(BitError(:,Type,Order,:,2:end),[1,5,2,3,4]);
SNR=permute(TotalSNR(:,Type,Order,:,:),[1,5,2,3,4]);

Points=[1:17 19:121 123:200];
ErrorAux=ErrorAux(Points,:);
SNR=SNR(Points,:);

% ErrorAux=reshape(ErrorAux,[200*7*8,1,1,1,1]);
% SNR=reshape(SNR,[200*7*8,1,1,1,1]);
ErrorAux=ErrorAux(:);
SNR=SNR(:);

scatter(10*log10(SNR),10*log10(ErrorAux),10,'filled')
A=gca;
A.FontSize=13;
grid on
colormap jet
title(['\textbf{Probability of error - Modulation: ',ModulationType{Type},'}'],'Interpreter','latex','FontSize',20)
xlabel('SNR (dB)','Interpreter','latex','FontSize',18)
ylabel('$P_E$ (dB)','Interpreter','latex','FontSize',18)
end

L=arrayfun(@(x) [num2str(x),' bit(s) per symbol'],[1,2,4,6,8],'UniformOutput',0);

Le=legend(L,'Location','best');
Le.FontSize=12;
Le.Interpreter='latex';
Le.Title.String='\textbf{Modulation Order}';
axis([-5 30 -20 0])
end

% Theoretical Error --------------------------------
subplot(2,1,2)
x=linspace(1,100,1000);
y=2*qfunc(sqrt(x));
plot(10*log10(x),10*log10(y),'--k','LineWidth',2)

for cont=2:5
    b=[1,2,4,6,8];
    x1=[10^0.45,10^0.5,10^1.0,10^1.8];
    M=2.^b(cont);
    
    N=4*(sqrt(M)-2)^2+3*4*(sqrt(M)-2)+4*2;
    N=N/M;
    
    Modulation=Define_Modulation(1,1,1,b(cont),'QAM','on');
    
    x=linspace(x1(cont-1),1000,1000);
    y=N*qfunc(Modulation.MinDistance.*sqrt(x)/2)/(b(cont)-1);
    plot(10*log10(x),10*log10(y),'--k','LineWidth',2);
end

subplot(2,1,1)
x=linspace(1,100,1000);
y=2*qfunc(sqrt(x));
plot(10*log10(x),10*log10(y),'--k','LineWidth',2)
for cont=2:5
    b=[1,2,4,6,8];
    x1=[10^0.45,10^0.5,10^1.5,10^3];
    M=2.^b(cont);
    
    x=linspace(x1(cont-1),10000,10000);
    
%     theta=linspace(0,pi-pi/M,500);
%     dt=theta(2)-theta(1);
%     y=arrayfun(@(x) sum(exp(-x*sin(pi/M)^2./sin(theta+pi/M).^2/2)*dt),x)/pi;
%     y=y/(b(cont)-1);
    
    Modulation=Define_Modulation(1,1,1,b(cont),'PSK','on');
    N=2;
    y=N*qfunc(Modulation.MinDistance.*sqrt(x)/2)/(b(cont)-1);
    
    plot(10*log10(x),10*log10(y),'--k','LineWidth',2);
%     plot(10*log10(x),10*log10(y2),'--m','LineWidth',2);
end
%------------------------------------------------------
