function a = gravity(r, C)
%GRAVITY Central gravitational acceleration.
%
% Input:
%   r - Position vector in ECI frame [km]
%   C - Structure with orbital constants
%
% Output:
%   a - Gravitational acceleration [km/s^2]

%% Position magnitude

r_norm = norm(r);

%% Central gravitational acceleration

a = (-C.mu / r_norm^3) * r;

end