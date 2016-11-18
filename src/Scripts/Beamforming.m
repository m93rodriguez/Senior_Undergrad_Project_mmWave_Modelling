%% Analyze Angular Spectrum

main
psinc=@(x,N) sin(x*N/2)./sin(x/2);
% Get the angular link power

PowerProfile=MIMO_CIR.PDP;

GetPower=@(x) sum(x(:));

AngularSpectrum=cellfun(GetPower,PowerProfile);
[~,I]=max(AngularSpectrum);
AOD=MIMO_CIR.AOD;
AOD_Max=AOD(I);
AOA=MIMO_CIR.AOA;
AOA_Max=AOA(I);
theta=linspace(0,2*pi,500);

clf

subplot(1,2,1)
Plot_polar_dB(AOD,AngularSpectrum/max(AngularSpectrum),30,'*')
hold on
Theo=psinc((sin(theta)-sin(AOD_Max))*pi,8);
polar(theta,abs(Theo)/8);


subplot(1,2,2)
Plot_polar_dB(AOA,AngularSpectrum/max(AngularSpectrum),30,'*')
hold on
Theo=psinc((sin(theta)-sin(AOA_Max))*pi,8);
polar(theta,abs(Theo)/8);

