%% Narrowband SISO Channel

h_Narrow=SISO_CIR.h;
h_Narrow=sum(h_Narrow);

%% Phase Loop

h_Narrow=h_Narrow*exp(-1i*angle(h_Narrow));

%% System definition
Message_Length=500;
SymbolDuration=10;

%% BPSK

% Message Modulation

x=[];
Sent_Symbols=[];
for i=1:Message_Length
    Sent_Symbols(i)=(-1)^randi(2);
    x=[x ones(1,SymbolDuration)*Sent_Symbols(i)];
end

% Channel
y=conv(x,h_Narrow);
y=y+(normrnd(0,1,size(y))+1i*normrnd(0,1,size(y)))/4;

% Demodulation

MatchedFilter=ones(1,SymbolDuration);

y_d=conv(y,MatchedFilter);

Detected_Symbols=y_d(1:SymbolDuration:end);
Detected_Symbols=Detected_Symbols(2:end);
In_Phase=real(Detected_Symbols);
Quadrature=imag(Detected_Symbols);

subplot(2,2,1)
hold on
plot(Sent_Symbols,'-*')
plot(In_Phase,'-*');
plot(Quadrature,'-*')
hold off

subplot(2,2,2), plot(In_Phase,Quadrature,'*')

%% QPSK

% Message Modulation

x=[];
Sent_Symbols=[];
for i=1:Message_Length
    Sent_Symbols(i)=(1i)^randi(4)*exp(1i*pi/4);
    x=[x ones(1,SymbolDuration)*Sent_Symbols(i)];
end

Sent_I=real(Sent_Symbols);
Sent_Q=imag(Sent_Symbols);

% Channel
y=conv(x,h_Narrow);
y=y+(normrnd(0,1,size(y))+1i*normrnd(0,1,size(y)))/10;

% Demodulation

MatchedFilter=ones(1,SymbolDuration);

y_d=conv(y,MatchedFilter);

Detected_Symbols=y_d(1:SymbolDuration:end);
Detected_Symbols=Detected_Symbols(2:end);
In_Phase=real(Detected_Symbols);
Quadrature=imag(Detected_Symbols);

subplot(2,2,3)
hold on
plot(Sent_I,'-*')
plot(Sent_Q,'-*')
plot(In_Phase,'-*');
plot(Quadrature,'-*')
hold off

subplot(2,2,4), plot(In_Phase,Quadrature,'*')
