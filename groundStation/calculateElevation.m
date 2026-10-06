function elevation = calculateElevation(rSat, epoch, station, C)

%CALCULATEELEVATION Calculate spacecraft elevation angle
% as seen from a ground station.
%
% Input:
%   rSat    - Spacecraft position in ECI/J2000 [km]
%   epoch   - Absolute UTC epoch [datetime]
%   station - Ground station data
%   C       - Physical constants
%
% Output:
%   elevation - Elevation angle [deg]

%% Station parameters

lat = deg2rad(station.lat);
lon = deg2rad(station.lon);
h   = station.alt;

%% Station position in ECEF

% WGS-84 ellipsoid

a = 6378.137;              % Equatorial radius [km]
f = 1 / 298.257223563;     % Flattening
e2 = f * (2 - f);          % First eccentricity squared

N = a / sqrt(1 - e2 * sin(lat)^2);

rStationECEF = [

    (N + h) * cos(lat) * cos(lon);

    (N + h) * cos(lat) * sin(lon);

    (N * (1 - e2) + h) * sin(lat)

];

%% Greenwich Mean Sidereal Time

JD = juliandate(epoch);

T = (JD - 2451545.0) / 36525;

theta = ...
    280.46061837 ...
    + 360.98564736629 * (JD - 2451545.0) ...
    + 0.000387933 * T^2 ...
    - T^3 / 38710000;

theta = mod(theta, 360);

theta = deg2rad(theta);

%% Earth rotation: ECI -> ECEF

R3 = [

     cos(theta)   sin(theta)   0;
    -sin(theta)   cos(theta)   0;
     0            0            1

];

%% Station position in ECI

rStationECI = R3' * rStationECEF;

%% Line of sight in ECI

rhoECI = rSat - rStationECI;

%% Line of sight in ECEF

rSatECEF = R3 * rSat;

rhoECEF = R3 * rhoECI;

%% Local vertical

up = rStationECEF / norm(rStationECEF);

%% Elevation angle

elevation = asin( ...
    dot(rhoECEF, up) / norm(rhoECEF));

elevation = rad2deg(elevation);

end