%% Process Experiment 1 Results

% Variable Structure:
% - TimeStatistics : Cell in which each position is a structure with
% fields:
%   - MeanDelaySpread
%   - RMSDelaySpread
%   - MaxExcessDelay
%
% - Error: 5-D cell. Dimentions: {CIR,Modulation Type,Time Factor,
% Modulation Order, SNR}. Each position is a structure with fields:
%   - TotalBitError
%   - InSymbols
%   - OutSymbols
%   - SymbolError
%   - BitError
%
% Resolution for bit error: Stream length=10000 - Res = 1e-4
%% Delay Spread Statistics

N=length(Resultados.TimeStatistics);
RMS_Vector=zeros(1,N);
for i=1:N
    RMS_Vector(i)=Resultados.TimeStatistics{i}.RMSDelaySpread;
end %Variable i

%% Gain Statistics

N=length(Resultados.Gain);
Gain_Vector=zeros(1,N);
for i=1:N
    Gain_Vector(i)=Resultados.Gain{i};
end %Variable i

[CDF,pos]=histcounts(Gain_Vector,20,'Normalization','cdf');
pos=pos(2:end);

% Rayleigh CDF
CDF_Rayleigh=raylcdf(pos,mean(Gain_Vector)/sqrt(pi/2));

% Log-Normal CDF
mu=log(mean(Gain_Vector)/sqrt(1+var(Gain_Vector)/mean(Gain_Vector)^2));
sigma=sqrt(log(1+var(Gain_Vector)/mean(Gain_Vector)^2));
CDF_Log=normcdf((log(pos)-mu)/sigma);

% Plot CDFs
figure
hold on
plot(pos,(CDF),'-*b')
plot(pos,(CDF_Rayleigh),'-ro')
plot(pos,(CDF_Log),'-dk');
hold off
legend('Data CDF','Rayleigh CDF','Log-Normal CDF','Location','best')
xlabel('RMS Delay Spread (ns)')
ylabel('Probability')
title('RMS Delay Spread Cumulative Density Function (CDF)')
%% Error Analysis
Error=cell(size(Resultados.Error,3),size(Resultados.Error,4),2);
Error_Variance=Error;
for Type=1:2
    for Time=1:size(Resultados.Error,3)
        for Order=1:size(Resultados.Error,4)
            Error_aux=zeros(N,size(Resultados.Error,5));
            for cont=1:N
                for SNR=1:size(Resultados.Error,5)
                    Error_aux(cont,SNR)=Resultados.Error{cont,Type,Time,Order,SNR}.TotalBitError;
                end % Variable SNR
                Error{Time,Order,Type}=mean(Error_aux);
                Error_Variance{Time,Order,Type}=var(Error_aux);
            end % Variable N - Number of CIRs
        end % Variable Order
    end % Variable Time - Narrowband Factor
end % Type

%% Plotting
SNR_Range=linspace(0.1,5,10); % min 0.1, max 5, Num points 10
% SNR vs Time
figure
for i=1:7
    subplot(2,4,i)
    for j=1:10
        hold on
        plot((SNR_Range),(Error{j,i,2}));
    end
    legend('1','2','3','4','5','6','7','8','9','10')
    title(['Modulation Order (PSK): ',num2str(i)])
    xlabel('Signal to Noise Ratio')
    ylabel('Probability of Error')
    hold off
    grid
end

% Modulations
figure
for i=1:7
    hold on
    plot((SNR_Range),(Error{end,i,2}))
    leg{i}=['Modulation Order: ',num2str(i)];
end
title('Modulation Order Comparison')
xlabel('Signal to Noise Ratio')
ylabel('Probability of Error')
legend(leg)
grid
% QAM vs PSK

figure
for i=1:6
    subplot(2,3,i)
    hold on
    for j=1:2
        plot(SNR_Range,Error{end,i+j-1,j});
        
        
    end
    legend('QAM','PSK')
    title(['Modulation Order: ',num2str(i+1)])
    xlabel('Signal to Noise Ratio');
    ylabel('Probability of Error')
    hold off
    grid
end


