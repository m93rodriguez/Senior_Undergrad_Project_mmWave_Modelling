v=-5:0.02:5;
F=zeros(size(v));
for x=1:length(v)
    t=linspace(v(x),200,100000);
    dt=t(2)-t(1);
    F(x)=sum(exp(-1i*(t.^2)*pi/2));
    F(x)=F(x)*(1+1i)/2*dt;
end

G=figure(1);
G.Position=[884 337 998 623];

plot(v,abs(F),'LineWidth',1.5)
set(gca,'FontSize',13)
xlabel('$\nu$','Interpreter','latex','FontSize',18)
ylabel('$|F(\nu)|$','Interpreter','latex','FontSize',18)
title('\textbf{Difraction Power Gain}','Interpreter','latex', 'FontSize',20)
grid on