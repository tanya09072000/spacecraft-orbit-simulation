function Data = inputData()
%INPUTDATA Input data for the orbital simulation.
%
% Output:
%   Data - Structure containing all simulation input parameters:
%          Scenario
%          Spacecraft
%          Orbit
%          OrbitTolerance
%          Station
%          Environment
%          Model

projectRoot = fileparts(fileparts(mfilename('fullpath')));

%% Launch parameters
Scenario.launchTime     = datetime(2026, 09, 19, 4, 30, 0);
Scenario.separationTime = datetime(2026,09,19,4,38,11);
Scenario.duration = days(4);
Scenario.stopTime = Scenario.separationTime + Scenario.duration;
Scenario.timeSystem = "UTC";
Scenario.frame = "ECI";

%% Spacecraft parameters

Spacecraft.mass = 500;          % Spacecraft mass [kg]
Spacecraft.area = 2.5;          % Reference cross-sectional area [m^2]
Spacecraft.Cr = 1.3;            % Reflectivity coefficient

%% Initial state after separation
%
% State vector received from the upper stage after spacecraft separation.
% Position [km]
% Velocity [km/s]

InitialState.mode = "OrbitalElements";
InitialState.epoch = Scenario.separationTime;
InitialState.position = [];
InitialState.velocity = [];

%% Nominal orbit

Orbit.a    = 6872.526;      % Semi-major axis [km]
Orbit.e    = 0.00135;       % Eccentricity
Orbit.i    = 97.455;        % Inclination [deg]
Orbit.raan = 0;
Orbit.argPerigee = 0;
Orbit.trueAnomaly = 0;
Orbit.LTAN = hours(10);     % Local Time of Ascending Node

%% Allowable deviations

OrbitTolerance.dT = 4;          % Time deviation [s]
OrbitTolerance.di = 3;          % Inclination deviation [arcmin]
OrbitTolerance.de = 0.001;      % Eccentricity deviation
OrbitTolerance.dOmega = 3;      % RAAN deviation [arcmin]


%% Ground stations

Station(1).name = "Station_1";
Station(1).lat = NaN;
Station(1).lon = NaN;
Station(1).alt = 0.05;
Station(1).minElevation = 7;

Station(2).name = "Station_2";
Station(2).lat = NaN;
Station(2).lon = NaN;
Station(2).alt = 0.09;
Station(2).minElevation = 7;

% Load local station configuration
privateConfig = fullfile(projectRoot, 'config', 'privateStations.m');

if isfile(privateConfig)
    Station = privateStations();
else
    error(['Station coordinates are missing. ', ...
           'Create config/privateStations.m locally.']);
end

%% Atmospheric model

Environment.model = "NRLMSISE";    % "NRLMSISE", "CIRA", "Exponential"
Environment.updateStep = hours(1);  % Atmosphere update interval

%% Dynamic model

Model.J2   = true;
Model.drag = true;
Model.SRP  = true;
Model.sun  = true;
Model.moon = true;

%% Aerodynamic model

Aerodynamics.model = "Legacy";      % "Legacy", "Sentman1961", "SchaafChambre"

%% Validation

Validation.enable = true;

Data.Scenario = Scenario;
Data.Spacecraft = Spacecraft;
Data.Orbit = Orbit;
Data.OrbitTolerance = OrbitTolerance;
Data.Station = Station;
Data.Environment = Environment;
Data.Model = Model;
Data.InitialState = InitialState;
Data.Aerodynamics = Aerodynamics;
Data.Validation = Validation;

end