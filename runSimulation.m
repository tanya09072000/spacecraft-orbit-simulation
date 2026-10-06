function Results = runSimulation(Data)
%RUNSIMULATION Run spacecraft orbital simulation.
%
% Input:
%   Data - Structure containing simulation parameters.
%
% Output:
%   Results - Structure containing simulation results.

%% Project path

projectRoot = fileparts(mfilename('fullpath'));

%% Physical constants

C = orbConstants();

%% Load SPICE kernels if required

if Data.Model.sun || Data.Model.moon || Data.Model.SRP

    kernelDir = fullfile(projectRoot,'Ephemerides','kernels');

    cspice_furnsh(fullfile(kernelDir,'naif0012.tls'));
    cspice_furnsh(fullfile(kernelDir,'de440.bsp'));

end

%% SPICE initial epoch

Data.SPICE.et0 = cspice_str2et( ...
    datestr(Data.Scenario.separationTime, ...
    'yyyy-mm-ddTHH:MM:SS.FFF'));

%% Initial state

switch Data.InitialState.mode

    case "OrbitalElements"

        % Generate the initial state from orbital elements.

        elements = [ ...
            Data.Orbit.a
            Data.Orbit.e
            Data.Orbit.i
            Data.Orbit.raan
            Data.Orbit.argPerigee
            Data.Orbit.trueAnomaly];

        Data.InitialState.y0 = ...
            orbitalElementsToStateVector(elements, C);

        Data.InitialState.position = ...
            Data.InitialState.y0(1:3);

        Data.InitialState.velocity = ...
            Data.InitialState.y0(4:6);

        Data.InitialState.source = ...
            "Orbital elements";


    case "StateVector"

        % Use the specified state vector.

        Data.InitialState.position = ...
            Data.InitialState.position(:);

        Data.InitialState.velocity = ...
            Data.InitialState.velocity(:);

        if numel(Data.InitialState.position) ~= 3 || ...
           numel(Data.InitialState.velocity) ~= 3

            error(['State vector must contain 3 position ', ...
                   'and 3 velocity components.']);

        end

        Data.InitialState.y0 = [ ...
            Data.InitialState.position;
            Data.InitialState.velocity];

        Data.InitialState.source = ...
            "State vector";


    otherwise

        error('Unknown initial state mode.');

end

%% Build atmosphere

if Data.Model.drag

    current_dt = Data.Scenario.separationTime;

    Data.Atmosphere = buildAtmosphere( ...
        Data, ...
        current_dt, ...
        Data.InitialState.position, ...
        C);

end

%% Orbit propagation

Trajectory = propagateOrbit(Data, C);

%% Communication analysis

Visibility = calculateVisibility( ...
    Trajectory, ...
    Data, ...
    C);

%% Orbital elements

OrbitHistory = calculateOrbitalElements( ...
    Trajectory, ...
    C);

%% Ascending-node analysis

AscendingHistory = extractAscendingNode( ...
    Trajectory, ...
    C, ...
    Data);

%% Simulation summary

Summary = createSimulationSummary( ...
    Trajectory, ...
    OrbitHistory, ...
    AscendingHistory, ...
    Data, ...
    C);

%% Collect results

Results.Trajectory = Trajectory;
Results.Visibility = Visibility;
Results.Orbit = OrbitHistory;
Results.AscendingNode = AscendingHistory;
Results.Summary = Summary;

if Data.Model.drag
    Results.Atmosphere = Data.Atmosphere;
end

Results.Data = Data;
Results.Constants = C;

end