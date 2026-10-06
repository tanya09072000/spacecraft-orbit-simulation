function dy = orbitalDynamics(t, y, C, Data)
%ORBITALDYNAMICS Compute spacecraft state derivatives.
%
% Input:
%   t    - Time since separation [s]
%   y    - State vector [x y z vx vy vz]
%        Position [km], velocity [km/s]
%   C    - Physical constants
%   Data - Simulation and model parameters
%
% Output:
%   dy   - State derivative [vx vy vz ax ay az]
%          Velocity [km/s], acceleration [km/s^2]


%% Current state

r = y(1:3);
v = y(4:6);

%% Central gravity

aCentral = gravity(r, C);

%% Initialize perturbation accelerations

aJ2   = zeros(3,1);
aDrag = zeros(3,1);
aSRP  = zeros(3,1);
aSun  = zeros(3,1);
aMoon = zeros(3,1);

%% SPICE ephemeris time

et = Data.SPICE.et0 + t;

%% Sun position

rSun = [];

if Data.Model.SRP || Data.Model.sun
    rSun = bodyPosition('SUN', et);
end

%% Moon position

rMoon = [];

if Data.Model.moon
    rMoon = bodyPosition('MOON', et);
end

%% J2

if Data.Model.J2
    aJ2 = gravityJ2(r, C);
end

%% Atmospheric drag

if Data.Model.drag
    aDrag = drag(t, r, v, Data, C);
end

%% Solar radiation pressure

if Data.Model.SRP
    aSRP = solarRadiationPressure( ...
        t, r, Data, C, rSun);
end

%% Sun gravity

if Data.Model.sun
    aSun = sunGravity( ...
        r, rSun, C);
end

%% Moon gravity

if Data.Model.moon
    aMoon = moonGravity( ...
        r, rMoon, C);
end

%% Total acceleration

aTotal = aCentral + ...
         aJ2 + ...
         aDrag + ...
         aSRP + ...
         aSun + ...
         aMoon;

%% State derivative

dy = [v; aTotal];

end