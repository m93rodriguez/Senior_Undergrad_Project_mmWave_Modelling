function Plot_polar_dB(Angle,Gain,Range_dB,Properties)
if nargin < 4, Properties='b';end
if nargin < 3, Range_dB=20;end

Num_Rays=25;
Gain_Inc=round(Range_dB/5);

% Corrdinates
x_pos=cos(linspace(-pi,pi,360));
y_pos=sin(linspace(-pi,pi,360));
% Generate Circle plotting area
Area=patch;
Area.XData=x_pos;
Area.YData=y_pos;
Area.EdgeColor='black';
Area.FaceColor='white';
axis square;
axis off
hold on
% Circle indicator

Circle_Label=-Range_dB:Gain_Inc:0;
Circles=Circle_Label/-Range_dB;
for cont=2:length(Circles)-1
    C=polar(linspace(-pi,pi,360),Circles(cont)*ones(1,360));
    C.Color=[0.7 0.7 0.7];
    C.LineStyle='--';
    T=text(Circles(cont),0,...
        [num2str(Circle_Label(length(Circles)-cont+1)) ' dB']);
    T.VerticalAlignment='bottom';
    T.HorizontalAlignment='left';
end

% Ray indicators
Ray_Ang=linspace(0,2*pi,Num_Rays);
for cont=1:Num_Rays-1
    L=polar(Ray_Ang(cont)*ones(1,2),[0 1]);
    L.Color=[0.7 0.7 0.7];
    L.LineStyle='--';
    T=text(1.1*cos(Ray_Ang(cont)),1.1*sin(Ray_Ang(cont)),...
        [num2str(rad2deg(Ray_Ang(cont))) ' °']);
    T.HorizontalAlignment='center';
    T.VerticalAlignment='middle';
end

% Plot values
Gain_dB=10*log10(abs(Gain));
Gain_dB=max(Gain_dB,-Range_dB);
Gain_dB=(Gain_dB+Range_dB)/Range_dB;
polar(Angle,Gain_dB,Properties);
hold off
end