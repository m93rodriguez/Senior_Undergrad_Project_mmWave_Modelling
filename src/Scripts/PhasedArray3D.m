% clear all

lambda=Param.Phys.lambda;
%% Geometry Definition
Distance=1000*lambda;
phi=linspace(0,2*pi,70);
theta=linspace(-pi/2,pi/2,70);
[Theta,Phi,R]=meshgrid(theta,phi,Distance);

[x_Far,y_Far,z_Far]=sph2cart(Phi,Theta,R);

%% Antenna array definition

N=Param.System.Nt;
N=36;

pos=1:sqrt(N);
pos=Param.System.AntennaSeparation*(pos-mean(pos));

y_pos=pos'*ones(1,sqrt(N));
x_pos=ones(sqrt(N),1)*pos;

z_pos=zeros(size(y_pos));


Phase=2*pi*rand(1,N);
Phase=zeros(1,N);
Phase=3*(1:N)/2/pi;
% Phase=angle(TransmitMatrix*x);

% Video
Video=VideoWriter('Video.avi');
Video.FrameRate=10;
open(Video);

for k=0:0.1:50
    
Phase=k*(1:N)/2/pi;

%% Calculate phase shifts
Gain=zeros(size(x_Far));

for i=1:size(x_Far,1)
    for j=1:size(x_Far,2)
        for antenna=1:N
            d=(x_Far(i,j)-x_pos(antenna)).^2+(y_Far(i,j)-y_pos(antenna)).^2+...
                (z_Far(i,j)-z_pos(antenna)).^2;
            d=sqrt(d);
            Gain(i,j)=Gain(i,j)+exp(1i*(2*pi*d/lambda+Phase(antenna)));
        end
    end
end

Gain=Gain/N;
[x_gain,y_gain,z_gain]=sph2cart(Phi,Theta,abs(Gain));
%% Plotting

plot3([-1 1 0 0 0 0],[0 0 -1 1 0 0],[0 0 0 0 -1 1],'.')
hold on
S=surf(x_gain,y_gain,z_gain,abs(Gain));
S.FaceColor='interp';
S.LineStyle=':';
axis image
colormap jet
caxis([0 1])

T=title('Antenna array emission pattern');
xlabel('X-Direction Gain');
ylabel('Y-Direction Gain');
zlabel('Z-Direction Gain')

print('Imagen.png','-dpng');
frame=imread('Imagen.png');
writeVideo(Video,frame);

hold off
end

