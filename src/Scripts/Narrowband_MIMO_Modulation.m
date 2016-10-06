% close all
%% MIMO Channel

H=zeros(Param.System.Nr,Param.System.Nt);
for i=1:Param.System.Nr
    for j=1:Param.System.Nt
        H(i,j)=sum(MIMO_CIR.h{i,j});
    end
end

RMS_DS=Statistics_MIMO.RMSDelaySpread;

% Coherence Bandwidth

Time_Duration=100*RMS_DS;
Index_Duration=ceil(Time_Duration/Param.System.TimeResolution);

%% Phase Correcction
Phase_Shift=angle(H);
%% Message Definition
Message_Length=1000;
SymbolDuration=Index_Duration;

%% Independent Channels - Spatial Multiplexing

[ReceiveMatrix,Gain,TransmitMatrix]=svd(H);

%% Signal Generation - BPSK

SentBits=(-1).^(randi(2,1,Message_Length));

%% Modulation and Demodulation
ReceivedBits=[];
N=Param.System.Nt;
for cont=1:Message_Length/Param.System.Nt
    y=[];
    % Mux
    x_Bits=SentBits((cont-1)*N+1:cont*N)';
    
    % Modulate and send
    for SymbolTime=1:SymbolDuration
        x=x_Bits;
        y(:,SymbolTime)=ReceiveMatrix'*H*TransmitMatrix*x;
    end
    % Demodulate
    y=y+(randn(size(y))+1i*randn(size(y)))/1;
    y_d=y*ones(SymbolDuration,1)/sum(SymbolDuration);
    y_Bits=inv(Gain)*y_d;
    
    %Demux
    ReceivedBits=[ReceivedBits y_Bits'];
end

figure
scatter(real(ReceivedBits),imag(ReceivedBits),30,SentBits,'filled')
colormap winter


