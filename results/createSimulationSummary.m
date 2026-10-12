function Summary = createSimulationSummary( ...
    Trajectory, OrbitHistory, AscendingHistory, Data, C)
%CREATESIMULATIONSUMMARY Calculate key simulation results.
%
% Input:
%   Trajectory       - Propagated trajectory
%   OrbitHistory     - Orbital element history
%   AscendingHistory - Ascending node history
%   Data             - Simulation input data
%   C                - Physical constants
%
% Output:
%   Summary - Structure containing key simulation results.

%% Check ascending-node data

if isempty(AscendingHistory.time)

    error('No ascending node crossings found in trajectory.');

end

%% Initial state after separation

elementsInitialState = stateVectorToOrbitalElements(Trajectory.state(1,:), C);

%% First ascending node

a0 = AscendingHistory.a(1);
e0 = AscendingHistory.e(1);

i0 = AscendingHistory.i(1);
raan0 = AscendingHistory.raan(1);
omega0 = AscendingHistory.argPerigee(1);
nu0 = AscendingHistory.trueAnomaly(1);


%% Last ascending node

aF = AscendingHistory.a(end);
eF = AscendingHistory.e(end);

iF = AscendingHistory.i(end);
raanF = AscendingHistory.raan(end);
omegaF = AscendingHistory.argPerigee(end);
nuF = AscendingHistory.trueAnomaly(end);

%% Perigee altitude

perigeeAltitude0 = a0 * (1 - e0) - C.Re;

perigeeAltitudeF = aF * (1 - eF) - C.Re;

perigeeAltitudeChange = perigeeAltitudeF - perigeeAltitude0;


%% Apogee altitude

apogeeAltitude0 = a0 * (1 + e0) - C.Re;

apogeeAltitudeF = aF * (1 + eF) - C.Re;

apogeeAltitudeChange = apogeeAltitudeF - apogeeAltitude0;

%% Altitude at ascending node

ascendingNodeAltitude0 = ...
    AscendingHistory.height(1);

ascendingNodeAltitudeF = ...
    AscendingHistory.height(end);

ascendingNodeAltitudeChange = ...
    ascendingNodeAltitudeF - ascendingNodeAltitude0;

%% Semi-major axis change

semiMajorAxisChange = aF - a0;

%% Number of revolutions

argumentOfLatitude = ...
    deg2rad( ...
        OrbitHistory.argPerigee + ...
        OrbitHistory.trueAnomaly);

% Remove discontinuities at 360 -> 0 degrees.

argumentOfLatitude = unwrap(argumentOfLatitude);

% Total accumulated angular motion.

deltaU = ...
    argumentOfLatitude(end) - ...
    argumentOfLatitude(1);

% Total number of revolutions.

totalRevolutions = deltaU / (2*pi);

% Number of complete revolutions.

completedRevolutions = floor(totalRevolutions);

%% Orbital period

% Total propagation time.

totalTime = ...
    Trajectory.time(end) - ...
    Trajectory.time(1);

% Mean orbital period obtained from the simulation.

meanPeriod = totalTime / totalRevolutions;

%% Keplerian period

keplerPeriod = 2*pi*sqrt(a0^3 / C.mu);

%% Difference between simulated and Keplerian period

periodDifference = ...
    meanPeriod - keplerPeriod;

periodDifferencePercent = ...
    periodDifference / keplerPeriod * 100;

%% First and last ascending node epoch

firstAscendingNode = ...
    Data.Scenario.separationTime + ...
    seconds(AscendingHistory.time(1));

lastAscendingNode = ...
    Data.Scenario.separationTime + ...
    seconds(AscendingHistory.time(end));

%% Integration points

integrationPoints = size(Trajectory.state, 1);

%% Store initial state information

Summary.initialStateSource = ...
    Data.InitialState.source;

Summary.initialElements = ...
    elementsInitialState;

%% Store ascending-node orbital elements

Summary.initialAscendingNodeElements = [
    a0
    e0
    deg2rad(i0)
    deg2rad(raan0)
    deg2rad(omega0)
    deg2rad(nu0)
];

Summary.finalAscendingNodeElements = [
    aF
    eF
    deg2rad(iF)
    deg2rad(raanF)
    deg2rad(omegaF)
    deg2rad(nuF)
];

%% Store semi-major axis information

Summary.initialSemiMajorAxis = a0;

Summary.finalSemiMajorAxis = aF;

Summary.semiMajorAxisChange = semiMajorAxisChange;

%% Store perigee information

Summary.initialPerigeeAltitude = perigeeAltitude0;

Summary.finalPerigeeAltitude = perigeeAltitudeF;

Summary.perigeeAltitudeChange = perigeeAltitudeChange;

%% Store apogee information

Summary.initialApogeeAltitude = apogeeAltitude0;

Summary.finalApogeeAltitude = apogeeAltitudeF;

Summary.apogeeAltitudeChange = apogeeAltitudeChange;

%% Store ascending-node altitude information

Summary.initialAscendingNodeAltitude = ascendingNodeAltitude0;

Summary.finalAscendingNodeAltitude = ascendingNodeAltitudeF;

Summary.ascendingNodeAltitudeChange = ascendingNodeAltitudeChange;

%% Store ascending-node information

Summary.lastAscendingNode = lastAscendingNode;
Summary.firstAscendingNode = firstAscendingNode;

%% Store revolution information

Summary.totalRevolutions = totalRevolutions;

Summary.completedRevolutions = completedRevolutions;

%% Store orbital period information

Summary.meanPeriod = meanPeriod;

Summary.keplerPeriod = keplerPeriod;

Summary.periodDifference = periodDifference;

Summary.periodDifferencePercent = periodDifferencePercent;

%% Store propagation information

Summary.integrationPoints = integrationPoints;

end