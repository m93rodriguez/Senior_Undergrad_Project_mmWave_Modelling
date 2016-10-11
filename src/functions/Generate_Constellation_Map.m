function ConstellationMap=Generate_Constellation_Map(num_bits,type)


if nargin<2, type='QAM'; end

num_symbols=2^num_bits;

if strcmp(type,'QAM')
    Constellation_Length=sqrt(num_symbols);
    
    Distance=2;
    Positions=Distance*(1:Constellation_Length);
    Positions=Positions-mean(Positions);
    
    Quadrature=Positions'*ones(size(Positions));
    InPhase=Quadrature';
    Quadrature=-1i*Quadrature;
    ConstellationMap=InPhase(:)'+Quadrature(:)';
    
elseif strcmp(type,'PSK')
    
    Angle_Separation=2*pi/num_symbols;
    Angle=Angle_Separation/2:Angle_Separation:2*pi-Angle_Separation/2;
    ConstellationMap=exp(1i*Angle);
    
end

end



