function main()

%MAIN Main program for spacecraft orbital simulation.
%
% Workflow:
%   1. Set project path
%   2. Read simulation input data
%   3. Run spacecraft simulation
%   4. Display results
%   5. Plot results

%% Project path

projectRoot = fileparts(mfilename('fullpath'));

addpath(genpath(projectRoot));

%% Input

Data = inputData();

validateInputData(Data);

%% Simulation

Results = runSimulation(Data);

%% Visualization

plotVisibility(Results.Visibility);

if Data.Model.drag

    plotAtmosphere( ...
        Results.Atmosphere, ...
        Data.Environment);

end

plotOrbitalElements(Results.AscendingNode);

%% Summary

simulationSummary(Results);

end