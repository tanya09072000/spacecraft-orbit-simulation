function a3B = thirdBodyAcceleration(rSat, rBody, muBody)
%THIRDBODYACCELERATION Compute third-body gravitational acceleration.
%
% Computes the perturbing acceleration due to a third body (e.g. Sun or
% Moon) acting on an Earth-orbiting spacecraft.
%
% Input:
%   rSat   - Spacecraft position vector in ECI [km]
%   rBody  - Third-body position vector in ECI [km]
%   muBody - Gravitational parameter of the third body [km^3/s^2]
%
% Output:
%   a3B    - Third-body gravitational acceleration [km/s^2]

%% Vector from spacecraft to third body

rRel = rBody - rSat;

%% Distances

dRel  = norm(rRel);
dBody = norm(rBody);

%% Third-body perturbing acceleration

a3B = muBody * ( ...
      rRel  / dRel^3 ...
    - rBody / dBody^3 );

end