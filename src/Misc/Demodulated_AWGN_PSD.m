% This script helps to see the effect of the matched filter effect on a
% white noise. The autocorrelation and fourier transform operations are
% time-normalized.

L=20;
r=zeros(1000,(10000+L-1)*2-1);
h=ones(1,L)/sqrt(L);

for cont=1:1000
x=randn(1,10000);
x=2*x;
y=conv(x,h);
r(cont,:)=xcorr(y)/(y*y')*var(y);
end

r=mean(r);
R=fftshift(fft(r,length(r)*100));
R=R/L;
f=linspace(-0.5,0.5,length(R));
plot(f,abs(R))

grid

