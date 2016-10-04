%% Initialization
clear all
close all
clc

% Read Input parameters
Input_Parameters
addpath functions

%% Channel Impulse Response

% Stablish number of clusters and sub clusters
ClusterNumber=max([1 poissrnd(Param.Time.MeanClusterNumber)]);
SubclusterNumber=max([poissrnd(Param.Time.MeanSubclusterNumber,1,ClusterNumber);...
    ones(1,ClusterNumber)]);

% Calculate SISO Channle Impulse Response
Path_Loss_dB=Generate_Path_Loss_dB(Param.Large);

TimePositions=Generate_Time_Positions(Param.Time,Param.System,...
    ClusterNumber,SubclusterNumber);

MultipathPower=Generate_Power(TimePositions,Param.Time);

MultipathPhase=Generate_Phase(TimePositions);

SpatialLobes=Generate_Spatial_Properties(Param.Spatial,TimePositions);

SISO_CIR=Generate_SISO_CIR(Param.System,TimePositions,MultipathPower,...
    MultipathPhase,SpatialLobes);

% Calculate MIMO Channel Impulse Response

CovarianceMatrix=Generate_Array_Covariance_Matrix(Param,TimePositions,SpatialLobes);
MIMO_CIR=Generate_MIMO_CIR(Param.System,CovarianceMatrix,MultipathPower,...
    MultipathPhase,TimePositions,SpatialLobes);


%% Narrowband Modulation (SISO)

