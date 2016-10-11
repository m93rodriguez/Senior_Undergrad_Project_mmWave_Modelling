%% Initialization
clear all
close all
clc

% Read Input parameters
Input_Parameters
addpath functions
addpath Scripts

%% Channel Impulse Response


CIR=System_Generation(Param);
SISO_CIR=CIR.SISO;
MIMO_CIR=CIR.MIMO;

Statistics_SISO=Extract_SISO_Statistics(SISO_CIR);
Statistics_MIMO=Extract_MIMO_Statistics(MIMO_CIR);

% Plot Local Area Response
% Plot_MIMO_Local_Area

%% Obtain Statistics
% N_Samples=30000;
% 
% MIMO_Delay=zeros(1,N_Samples);
% SISO_Delay=MIMO_Delay;
% 
% for cont=1:N_Samples;
% CIR=System_Generation(Param);
% SISO_CIR=CIR.SISO;
% MIMO_CIR=CIR.MIMO;
% 
% Statistics_SISO=Extract_SISO_Statistics(SISO_CIR);
% Statistics_MIMO=Extract_MIMO_Statistics(MIMO_CIR);
% 
% MIMO_Delay(cont)=Statistics_MIMO.RMSDelaySpread;
% SISO_Delay(cont)=Statistics_SISO.RMSDelaySpread;
% 
% fprintf([num2str(100*cont/N_Samples) '\n'])
% end
%  

%% Narrowband SISO Modulation
% Narrowband_SISO_Modulation
%% Narrowband MIMO Modulation
% Narrowband_MIMO_Modulation
