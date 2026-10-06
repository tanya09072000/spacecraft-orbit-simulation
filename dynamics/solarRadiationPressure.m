function aSRP = solarRadiationPressure(t, r, Data, C, rSun)
%SOLARRADIATIONPRESSURE Compute solar radiation pressure acceleration.
%
% Input:
%   t     - Time since separation [s]
%   r  - Spacecraft position vector in ECI [km]
%   Data  - Simulation input data
%   C     - Physical constants
%
% Output:
%   aSRP  - Solar radiation pressure acceleration [km/s^2]

%% Check whether spacecraft is inside Earth's shadow
if isInShadow(r, rSun, C)
    aSRP = zeros(3,1);
    return
end

%% Vector from Sun to spacecraft [m]
rSunSat = r - rSun;

%% Distance from Sun to spacecraft [m]
dSun = norm(rSunSat) * 1000;

%% Unit vector along solar rays
sHat = rSunSat / norm(rSunSat);

%% Solar radiation pressure at current distance
P = C.Psr * (C.AU/dSun)^2;

%% Acceleration [m/s^2]
aSRP = P*Data.Spacecraft.Cr*(Data.Spacecraft.area/Data.Spacecraft.mass)*sHat;

%% Converter to km/s^2
aSRP = aSRP/1000;

end