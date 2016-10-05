close all
%% SISO Channel
h=SISO_CIR.h;

RMS_DS=Statistics_SISO.RMSDelaySpread;

% Coherence Bandwidth
Time_Duration=100*RMS_DS;
Index_Duration=ceil(Time_Duration/Param.System.TimeResolution);

%% Phase Loop

Phase_Shift=sum(h);
Phase_Shift=angle(Phase_Shift);
h=h*exp(-1i*Phase_Shift);

%% Message Definition
Message_Length=500;
SymbolDuration=Index_Duration;
%% BPSK

% Message Modulation
x=[];
Sent_Symbols=[];
for i=1:Message_Length
    Sent_Symbols(i)=(-1)^randi(2);
    x=[x ones(1,SymbolDuration)*Sent_Symbols(i)];
end

% Channel
y=conv(x,h);
y=y+(normrnd(0,1,size(y))+1i*normrnd(0,1,size(y)))/5;

% Demodulation

MatchedFilter=ones(1,SymbolDuration)/SymbolDuration*5;

y_d=conv(y,MatchedFilter);

Detected_Symbols=y_d(1:SymbolDuration:end);
Detected_Symbols=Detected_Symbols(2:end);
In_Phase=real(Detected_Symbols);
Quadrature=imag(Detected_Symbols);

% Channel Plotting
subplot(2,2,1)
hold on
plot(Sent_Symbols,'-*')
plot(In_Phase,'-*');
plot(Quadrature,'-*')
hold off

subplot(2,2,2), %plot(In_Phase,Quadrature,'*')
scatter(In_Phase(1:Message_Length), Quadrature(1:Message_Length),30,Sent_Symbols(1:Message_Length), 'filled')
colormap winter

h_F=fftshift(fft(h,1024));
x_F=fftshift(fft(MatchedFilter,1024));
x_F=x_F/max(abs(x_F));

subplot(2,2,[3 4])
hold on
plot(abs(h_F))
plot(abs(x_F))

%% QPSK
% Message Modulation

x=[];
Sent_Symbols=[];
for i=1:Message_Length
    Sent_Bit(i)=randi(4);
    Sent_Symbols(i)=(1i)^Sent_Bit(i)*exp(1i*pi/4);
    x=[x ones(1,SymbolDuration)*Sent_Symbols(i)];
end

Sent_I=real(Sent_Symbols);
Sent_Q=imag(Sent_Symbols);

% Channel
y=conv(x,h);
y=y+(normrnd(0,1,size(y))+1i*normrnd(0,1,size(y)))/10;

% Demodulation

MatchedFilter=ones(1,SymbolDuration)/SymbolDuration*5;

y_d=conv(y,MatchedFilter);

Detected_Symbols=y_d(1:SymbolDuration:end);
Detected_Symbols=Detected_Symbols(2:end);
In_Phase=real(Detected_Symbols);
Quadrature=imag(Detected_Symbols);

% Plot

figure
subplot(2,2,1)
hold on
plot(Sent_I,'-*')
plot(Sent_Q,'-*')
plot(In_Phase,'-*');
plot(Quadrature,'-*')
hold off
subplot(2,2,2)
scatter(In_Phase(1:Message_Length), Quadrature(1:Message_Length),30,Sent_Bit(1:Message_Length), 'filled')
colormap jet
subplot(2,2,[3 4])
hold on
plot(abs(h_F))
plot(abs(x_F))
hold off
