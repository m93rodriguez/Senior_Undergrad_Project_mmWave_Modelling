function R=ArrayCovarianceULA(theta,RMS_AS,N,d,lambda)
%Covariance Matrix for ULA antenna array
% R=ArrayCovarianceULA(theta,RMS_AS,N,d,lambda) calculates the complex Hermitian
% Covariance Matrix R for the Uniform Linear Array (ULA) of N antennas
% separed by a distance d. lambda is the wavelength of the carrier. 
% It is assumed that the arriving multipath components arrive at a
% mean angle theta, following a Laplacian distribution with a RMS angle
% spread RMS_AS.

RMS_AS=deg2rad(RMS_AS);

% Generate the Laplacian PDF:
Num_Points=1000;
theta_vec=linspace(-pi,pi,Num_Points);
d_theta=mean(diff(theta_vec));
P_theta=exp(-abs(sqrt(2)*theta_vec/RMS_AS));
P_theta=P_theta/sum(P_theta*d_theta);


k=2*pi/lambda; % Wave number

R=eye(N); 

for m=1:N
    for n=1:m-1
        R(m,n)=sum(exp(1i*k*d*(m-n)*sin(theta-theta_vec)).*P_theta*d_theta);
        R(n,m)=R(m,n)';
    end
end

end