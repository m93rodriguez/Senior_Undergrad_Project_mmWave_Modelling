
theta=pi/2;
RMS_AS=deg2rad(360);
k=1:0.05:50;

d=k(1)*pi;
cont=1;
S=[];
for d=k*pi
Num_Points=1000;

t=linspace(-pi,pi,Num_Points);
dt=mean(diff(t));
P_theta=exp(-abs(sqrt(2)*t/RMS_AS));
P_theta=P_theta/sum(P_theta*dt);

S(cont)=sum(exp(1i*d*sin(theta-t)).*P_theta*dt);
cont=cont+1;
end
plot(abs(S))