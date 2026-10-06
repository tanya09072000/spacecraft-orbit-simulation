function runValidation()

%RUNVALIDATION Validate MATLAB visibility against STK results.

%% Project path

projectRoot = fileparts(mfilename('fullpath'));

addpath(genpath(projectRoot));

%% Validation tolerance

tolerance = 2.0;   % [s]

%% STK files

stkDir = fullfile(projectRoot, ...
    'validation', 'STK');

murmanskFile = fullfile( ...
    stkDir, ...
    'Satellite-KOEN-To-Facility-Murmansk Access.csv');

norilskFile = fullfile( ...
    stkDir, ...
    'Satellite-KOEN-To-Facility-Norilsk Access.csv');

%% Load STK data

STK_Murmansk = readSTKAccess(murmanskFile);

STK_Norilsk = readSTKAccess(norilskFile);

%% Calculate MATLAB visibility

C = orbConstants();

Data = inputData();

Trajectory = propagateOrbit(Data, C);

Visibility = calculateVisibility( ...
    Trajectory, Data, C);

%% MATLAB sessions

MATLAB_Murmansk = ...
    Visibility.stationData(1).sessions;

MATLAB_Norilsk = ...
    Visibility.stationData(2).sessions;

%% Validate Murmansk

Result.Murmansk = validateVisibility( ...
    STK_Murmansk, ...
    MATLAB_Murmansk, ...
    tolerance);

%% Validate Norilsk

Result.Norilsk = validateVisibility( ...
    STK_Norilsk, ...
    MATLAB_Norilsk, ...
    tolerance);

%% Print results

printVisibilityValidation( ...
    'Murmansk', ...
    Result.Murmansk);

printVisibilityValidation( ...
    'Norilsk', ...
    Result.Norilsk);

end