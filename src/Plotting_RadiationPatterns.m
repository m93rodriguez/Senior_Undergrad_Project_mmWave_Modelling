N=[4,6,8,16];
theta=linspace(-pi,pi,5000);
t0=deg2rad(30);
clf
for cont=1:4
    subplot(2,2,cont)
    Plot_polar_dB(theta,U(theta,t0,N(cont)),25)
    title({['\textbf{Radiation Pattern} $U(\theta)$, $N=$ ',num2str(N(cont))];''},'Interpreter','latex','FontSize',15)
end

