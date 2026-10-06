function orbitalElements = stateVectorToOrbitalElements(Y1, C)
%STATEVECTORTOORBITALELEMENTS Convert Cartesian state vector to
% classical orbital elements.
%
% Input:
%   Y1 - State vector [x y z vx vy vz]
%        Position [km], velocity [km/s]
%   C  - Physical constants
%
% Output:
%   orbitalElements - [a e i RAAN omega nu]
%                     a     [km]
%                     e     [-]
%                     i     [rad]
%                     RAAN  [rad]
%                     omega [rad]
%                     nu    [rad]

mu = C.mu;

%% Position and velocity

r_vec = Y1(1:3)';
v_vec = Y1(4:6)';

r = norm(r_vec);
v = norm(v_vec);

%% Semi-major axis

energy = v^2 / 2 - mu / r;

if energy >= 0
    error('stateVectorToOrbitalElements: orbit is not closed (energy = %.4g km^2/s^2)', energy);
end

a = -mu / (2 * energy);

%% Angular momentum and eccentricity

h_vec = cross(r_vec, v_vec);
h = norm(h_vec);

e_vec = cross(v_vec, h_vec) / mu - r_vec / r;
e = norm(e_vec);

%% Inclination

inc = acos(max(-1, min(1, h_vec(3) / h)));

%% Right ascension of ascending node

N_vec = cross([0; 0; 1], h_vec);
N = norm(N_vec);

if N < eps
    Omega = 0;
else
    Omega = acos(max(-1, min(1, N_vec(1) / N)));

    if N_vec(2) < 0
        Omega = 2*pi - Omega;
    end
end

%% Argument of perigee

if N < eps || e < eps
    omega = 0;
else
    omega = acos(max(-1, min(1, dot(N_vec, e_vec) / (N * e))));

    if e_vec(3) < 0
        omega = 2*pi - omega;
    end
end

%% True anomaly

nu = acos(max(-1, min(1, dot(e_vec, r_vec) / (e * r))));

if dot(r_vec, v_vec) < 0
    nu = 2*pi - nu;
end

%% Output

orbitalElements = [a, e, inc, Omega, omega, nu];

end