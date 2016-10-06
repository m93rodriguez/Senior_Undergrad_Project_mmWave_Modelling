
Fig_MIMO=figure('Position',[1 26 1920 973]);

 hold on
 TX_Antenna=1;
 for i=1:Param.System.Nr
     h=MIMO_CIR.h{i,TX_Antenna};
     PDP=h.*conj(h);
     Line(i)=plot3(1:length(PDP),Param.System.AntennaSeparation...
         *i*ones(size(PDP)),PDP);
 end
hold off
view([22 40])