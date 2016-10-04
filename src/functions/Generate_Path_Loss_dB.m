function Path_Loss=Generate_Path_Loss_dB(Param)
%dB path loss for wireless channel
% Path_Loss=Generate_Path_Loss_dB(Param) gives the random path loss
% according to the parameters contained in the input structure Param:
% Param.CloseIn close-in distance in meters
% Param.Shadowing Shadosing factor in dB
% Param.Exponent Path Loss exponent
% Param.Distance TX-RX separation in meters

Path_Loss_d0=20*log10(4*pi/Param.CloseIn);
Shadowing=normrnd(0,Param.Shadowing);
Path_Loss=Path_Loss_d0+...
    10*Param.Exponent*log10(Param.Distance/Param.CloseIn)+Shadowing;

end