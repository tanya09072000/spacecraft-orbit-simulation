function C = orbConstants()
%ORBCONSTANTS Physical and geodetic constants.
%
% Output:
%   C - Structure containing physical and Earth constants.

%% Earth constants

C.mu    = 398600.4415;      % Earth's gravitational parameter [km^3/s^2]
C.Re    = 6378.1363;         % Earth's equatorial radius [km]
C.omega = 7.2921150e-5;     % Earth's rotation rate [rad/s]
C.J2    = 1.08262668e-3;    % Second zonal harmonic coefficient

%% Gravitational parameters [km^3/s^2]

C.muMoon  = 4902.800076;
C.muMars  = 42828.375214;
C.muVenus = 324858.592000;

%% Physical constants
C.aem = 1.6605390666e-27;             % Atomic mass unit [kg]
C.k_b = 1.380649e-23;                 % Boltzmann constant [J/K]

%% WGS-84

C.f  = 1 / 298.257223563;                   % Flattening
C.e2 = C.f * (2 - C.f);                     % First eccentricity squared

%% Solar constants

C.muSun = 1.32712440018e11;      % Sun gravitational parameter [km^3/s^2]
C.AU = 149597870700;             % Astronomical Unit [m]
C.Psr = 4.56e-6;                 % Solar radiation pressure at 1 AU [N/m^2]

end
