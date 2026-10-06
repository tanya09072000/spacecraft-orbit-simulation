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

Station(1).name = "Murmansk";
Station(1).lat = 68.9717;       % Latitude [deg]
Station(1).lon = 33.0819;       % Longitude [deg]
Station(1).alt = 0.05;          % Altitude [km]
Station(1).minElevation = 7;    % Minimum elevation [deg]

Station(2).name = "Norilsk";
Station(2).lat = 69.3333;       % Latitude [deg]
Station(2).lon = 88.2167;       % Longitude [deg]
Station(2).alt = 0.09;          % Altitude [km]
Station(2).minElevation = 7;    % Minimum elevation [deg]

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