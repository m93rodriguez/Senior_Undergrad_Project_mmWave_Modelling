function Output=Simulate_Communication_Channel(Param,MIMO_CIR,...
    ModulationDefinition,NarrowbandFactor,SNR_Range,StreamLength)


% For ModulationDefinition the following fields are required:
% - BitsPerSymbol
% - Type
% - GrayCode


RMS_DS=Extract_MIMO_Statistics(MIMO_CIR);
RMS_DS=RMS_DS.RMSDelaySpread;

%
TransmitAntennas=MIMO_CIR.TransmitAntennas;
ReceiveAntennas=MIMO_CIR.ReceiveAntennas;
%
Output=cell(numel(NarrowbandFactor),numel(SNR_Range));

for cont_Time=1:numel(NarrowbandFactor) %% Cycle for Narrowband Factor
    
    Time_Duration=NarrowbandFactor(cont_Time)*RMS_DS;
    Index_Duration=ceil(Time_Duration/Param.System.TimeResolution);
    
    % Message Definition-------------------------------------------------------
    BinaryDigits='01';
    Stream=BinaryDigits(randi(2,1,StreamLength));
    % End Message Definition---------------------------------------------------
    
    % Prepare Modulation Definitions-------------------------------------------
    ModulationDefinition.ExcessTransmitAntennas=max(0,TransmitAntennas-ReceiveAntennas);
    ModulationDefinition.ExcessReceiveAntennas=max(0,ReceiveAntennas-TransmitAntennas);
    ModulationDefinition.SymbolDuration=Index_Duration;
    ModulationDefinition.PulseShape=ones(1,ModulationDefinition.SymbolDuration);
    
    [ModulationDefinition.GrayCodeMapping,ModulationDefinition.GrayCodeUnmapping]...
        =Graycode_Constellation_Mapping(ModulationDefinition);
    ModulationDefinition.ConstellationMap=cell(1,numel(ModulationDefinition.BitsPerSymbol));
    ModulationDefinition.ConstellationEnergy=zeros(1,numel(ModulationDefinition.BitsPerSymbol));
    for cont=1:numel(ModulationDefinition.BitsPerSymbol)
        [ModulationDefinition.ConstellationMap{cont},ModulationDefinition.ConstellationEnergy(cont)]=...
            Generate_Constellation_Map(ModulationDefinition.BitsPerSymbol(cont),...
            ModulationDefinition.Type);
    end
    % End Prepare Modulation Definitions---------------------------------------
    
    % Independent Channel Estimation...........................................
    H_Narrow=zeros(ReceiveAntennas,TransmitAntennas);
    for i=1:ReceiveAntennas
        for j=1:TransmitAntennas
            H_Narrow(i,j)=sum(MIMO_CIR.h{i,j});
        end
    end
    [ReceiveMatrix,Gain,TransmitMatrix]=svd(H_Narrow);
    GainVector=Gain(logical(eye(size(Gain))));
    % end Independent Channel Estimation.......................................
    
    % Modulation...............................................................
    % In this stage, the first process of Spatial Multiplexing is Applied
    x=Symbol_Modulation(Stream,ModulationDefinition);
    s=TransmitMatrix*x;
    s=s/sqrt(Param.System.Nt);% Normalize transmit power
    % end Modulation...........................................................
    
    % Receive Signal
    r=Matrix_Convolution_Fast(s,MIMO_CIR);
    % end Receive Signal
    for cont_SNR=1:numel(SNR_Range)%% Cycle for SNR
        NoisePowerDensity=mean(GainVector.^2)*ModulationDefinition.SymbolDuration/SNR_Range(cont_SNR);
        Noise=normrnd(0,sqrt(NoisePowerDensity),size(r))+1i*normrnd(0,sqrt(NoisePowerDensity),size(r));
        Noisy_Signal=r+Noise;
        
        % Demodulation.............................................................
        y=ReceiveMatrix'*Noisy_Signal;
        y=y*sqrt(Param.System.Nt);
        Demodulation=Symbol_Demodulation(y,Gain,ModulationDefinition);
        % end Demodulation ........................................................
        % Error Statistics.........................................................
        ErrorStatistics=Extract_Error_Statistics(Stream,ModulationDefinition,Demodulation);
        % end Error Statistics.....................................................
        
        % Interference Noise ..............................................
        InterferenceNoise=cell(min(TransmitAntennas,ReceiveAntennas),3);
        for cont=1:min(TransmitAntennas,ReceiveAntennas)
            InSymbols=ErrorStatistics.InSymbols(cont,:);
            OutSymbols=Demodulation.SymbolPosition{cont};
            OutSymbols=OutSymbols(1:length(InSymbols));
            GrayMap=ModulationDefinition.GrayCodeMapping{cont};
            Map=ModulationDefinition.ConstellationMap{cont};
            SymbolMeans=Map(GrayMap(InSymbols));
            InterferenceNoise{cont,1}=OutSymbols-SymbolMeans;
            Var=real(InterferenceNoise{cont,1});
            [h,p]=kstest((Var-mean(Var))/std(Var));
            InterferenceNoise{cont,2}=[h,p];
            Var=imag(InterferenceNoise{cont,1});
            [h,p]=kstest((Var-mean(Var))/std(Var));
            InterferenceNoise{cont,3}=[h,p];
        end %cont
        % end Interference Noise...........................................
        
        % Generate Output
        Output_Aux=struct;
        Output_Aux.ErrorStatistics=ErrorStatistics;
        Output_Aux.Demodulation=Demodulation;
        Output_Aux.GainVector=GainVector;
        Output_Aux.InterferenceNoise=InterferenceNoise;
        Output{cont_Time,cont_SNR}=Output_Aux;
    end %% end Cycle for SNR
end%% End Cycle for Narrowband Factor
end