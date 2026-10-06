function stateVec = orbitalElementsToStateVector(elements, C)
%ORBITALELEMENTSTOSTATEVECTOR Convert Keplerian elements to a Cartesian state vector.
%
% Input:
%   elements - Orbital elements:
%              [a, e, i, RAAN, omega, nu]
%              a     - Semi-major axis [km]
%              e     - Eccentricity
%              i     - Inclination [deg]
%              RAAN  - Right ascension of ascending node [deg]
%              omega - Argument of perigee [deg]
%              nu    - True anomaly [deg]
%
% Output:
%   stateVector - Cartesian state vector:
%                 [x, y, z, vx, vy, vz]
%                 Position [km]
%                 Velocity [km/s]

%% Orbital elements

a   = elements(1);
e   = elements(2);
inc   = deg2rad(elements(3));
raan  = deg2rad(elements(4));
argPerigee   = deg2rad(elements(5));
trueAnomaly  = deg2rad(elements(6));

%% Auxiliary parameters

mu = C.mu;

uu = argPerigee + trueAnomaly;

p  = a * (1 - e^2);
r  = p / (1 + e * cos(trueAnomaly));

Vr = sqrt(mu / p) * e * sin(trueAnomaly);
Vu = sqrt(mu * p) / r;

%% Position in inertial frame

x  =  r * (cos(raan)*cos(uu) - sin(raan)*sin(uu)*cos(inc));
y  =  r * (sin(raan)*cos(uu) + cos(raan)*sin(uu)*cos(inc));
z  =  r *  sin(uu) * sin(inc);

%% Velocity in inertial frame

Vx = Vr*(cos(raan)*cos(uu) - sin(raan)*sin(uu)*cos(inc)) - Vu*(cos(raan)*sin(uu) + sin(raan)*cos(uu)*cos(inc));
Vy = Vr*(sin(raan)*cos(uu) + cos(raan)*sin(uu)*cos(inc)) - Vu*(sin(raan)*sin(uu) - cos(raan)*cos(uu)*cos(inc));
Vz = Vr*sin(uu)*sin(inc) + Vu*cos(uu)*sin(inc);

%% State vector

stateVec = [x, y, z, Vx, Vy, Vz];

end
