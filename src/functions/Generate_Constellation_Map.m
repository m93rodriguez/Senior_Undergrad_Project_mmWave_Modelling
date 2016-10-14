function [ConstellationMap,MeanEnergy]=Generate_Constellation_Map(num_bits,type)

if nargin<2, type='QAM'; end

num_symbols=2^num_bits;

if strcmp(type,'QAM')
    Constellation_Length_X=2^ceil(num_bits/2);
    Constellation_Length_Y=2^floor(num_bits/2);
    
    Distance=2;
    Positions_X=Distance*(1:Constellation_Length_X);
    Positions_X=Positions_X-mean(Positions_X);
    Positions_Y=Distance*(1:Constellation_Length_Y);
    Positions_Y=Positions_Y-mean(Positions_Y);
    
    [InPhase,Quadrature]=meshgrid(Positions_X,Positions_Y);
    
    Quadrature=-1i*Quadrature;
    ConstellationMap=InPhase(:)'+Quadrature(:)';
    
elseif strcmp(type,'PSK')
    
    Angle_Separation=2*pi/num_symbols;
    Angle=Angle_Separation/2:Angle_Separation:2*pi-Angle_Separation/2;
    ConstellationMap=exp(1i*Angle);
    
end

MeanEnergy=ConstellationMap*ConstellationMap'/num_symbols;

end



