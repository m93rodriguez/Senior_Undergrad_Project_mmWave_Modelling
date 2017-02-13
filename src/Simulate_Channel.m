function ErrorStatistics=Simulate_Channel(MIMO_CIR,StreamLength,...
    SymbolDuration,BitsPerSymbol,NoisePowerDensity)

%% Prepare System
TransmitAntennas=MIMO_CIR.TransmitAntennas;
ReceiveAntennas=MIMO_CIR.ReceiveAntennas;

if numel(BitsPerSymbol)==1
    BitsPerSymbol=BitsPerSymbol*ones(1,min(TransmitAntennas,ReceiveAntennas));
end

% Message Definition-------------------------------------------------------
BinaryDigits='01';
Stream=BinaryDigits(randi(2,1,StreamLength));
% End Message Definition---------------------------------------------------

ModulationDefinition=Define_Modulation(TransmitAntennas,ReceiveAntennas,SymbolDuration,...
    BitsPerSymbol,'QAM','on');

% Spatial Mulitplexing gains and matrices----------------------------------

[SM_Rx,Gain,SM_Tx]=svd(MIMO_CIR.Narrowband);

% SM_Rx: Spatial Multiplexing Receive Matrix
% SM_Tx: Spatial Multiplexing Transmit Matrix

% GainVector=diag(Gain);
%--------------------------------------------------------------------------

%% Send and receive data
% Modulation --------------------------------------------------------------
x=Symbol_Modulation(Stream,ModulationDefinition);
s=SM_Tx*x;
s=s/sqrt(MIMO_CIR.TransmitAntennas);
% -------------------------------------------------------------------------

% Receive Signal ----------------------------------------------------------
r=Matrix_Convolution_Fast(s,MIMO_CIR);
%--------------------------------------------------------------------------
%% Noise
ErrorStatistics=cell(numel(NoisePowerDensity),1);
for cont_Noise=1:numel(NoisePowerDensity)
    
    % Additive White Gaussian Noise--------------------------------------------
    NoisePower=NoisePowerDensity(cont_Noise)/MIMO_CIR.ReceiveAntennas; % For SNR normalization
    Noise=normrnd(0,sqrt(NoisePower),size(r))+...
        1i*normrnd(0,sqrt(NoisePower),size(r));
    NoisySignal=r+Noise;
    % -------------------------------------------------------------------------
    
    %% Received signal analysis
    % Demodulation-------------------------------------------------------------
    y=SM_Rx'*NoisySignal;
    y=y*sqrt(MIMO_CIR.TransmitAntennas); % Amplify to Normalize Constellation;
    Demodulation=Symbol_Demodulation(y,Gain,ModulationDefinition);
    %--------------------------------------------------------------------------
    
    % Obtain Error Statistics--------------------------------------------------
    ErrorStatistics{cont_Noise}=Extract_Error_Statistics(Stream,ModulationDefinition,Demodulation);
    %--------------------------------------------------------------------------
    
    %% Interference Noise
    % Only when SNR=Inf
    
    InterferencePower=zeros(min(TransmitAntennas,ReceiveAntennas),3);
    
    if NoisePower==0
        for cont=1:min(TransmitAntennas,ReceiveAntennas)
            %-------
            InSymbols=Bit_Multiplexing(Stream,ModulationDefinition);
            InSymbols=InSymbols(cont,:);
            GrayMap=ModulationDefinition.GrayCodeMapping{cont};
            Map=ModulationDefinition.ConstellationMap{cont};
            InSymbols=Map(GrayMap(InSymbols));
            %-------------
            OutSymbols=Demodulation.SymbolPosition{cont};
            OutSymbols=OutSymbols(1:length(InSymbols));
            %---------------
            Interference=OutSymbols-InSymbols;
            InterferencePower(cont,1)=var(real(Interference));
            InterferencePower(cont,2)=var(imag(Interference));
            InterferencePower(cont,3)=var(Interference);
            %-------------
        end
        ErrorStatistics{cont_Noise}.Interference=InterferencePower;
    end
end
end

