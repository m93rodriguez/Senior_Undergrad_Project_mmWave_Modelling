function y=psinc(x,N)
%Periodic Sinc Function
% y=psinc(x,N) calculates the periodic sinc function of x. The result in y
% is periodic for x between 0 and 2*pi with N-1 zero crossings and absolute
% extrema at integer number of times 2*pi. The zero crossings are located
% at x=2*pi/k for k integer between 1 and N-1.

y=sin(N*x/2)./sin(x/2);
y(isnan(y))=N;
end
