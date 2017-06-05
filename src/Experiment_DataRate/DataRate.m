ModulationOrder=[1,2,4,6,8];
NumClusters=[16 8 4 2 1];
SymbolDuration=[20 27 40 60 100 160 200];
SymbolDuration_ns=[50 67.5 100 150 250 400 500];
SymbolDuration_MHz=[20 15 10 6.7 4 2.5 2];

load Experiment_DataRate\MeanValues.mat
% Mu
% Mu_ISI
BW=5;
for Order=1:5
    Aux=Define_Modulation(1,1,1,ModulationOrder(Order),'QAM','on');
    Aux=Aux.ConstellationEnergy;
    ModEnergy(Order)=Aux;
end

for Cluster=5
    Gain=10.^(Mu{Cluster}/10);
    ISI=Mu_ISI(Cluster,BW);
    
    E_r=Gain.*SymbolDuration(BW);
%     E_ISI=
end