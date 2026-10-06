function OrbitHistory = calculateOrbitalElements(Trajectory, C)
%CALCULATEORBITALELEMENTS Convert propagated state vectors to orbital elements.
%
% Input:
%   Trajectory - Propagated trajectory
%   C          - Physical constants
%
% Output:
%   OrbitHistory - Orbital elements history

n = length(Trajectory.time);

%% Preallocate memory

OrbitHistory.time = Trajectory.time;

OrbitHistory.a           = zeros(n,1);
OrbitHistory.e           = zeros(n,1);
OrbitHistory.i           = zeros(n,1);
OrbitHistory.raan        = zeros(n,1);
OrbitHistory.argPerigee  = zeros(n,1);
OrbitHistory.trueAnomaly = zeros(n,1);
OrbitHistory.height      = zeros(n,1);

%% Convert state vectors

for k = 1:n

    elements = stateVectorToOrbitalElements( ...
        Trajectory.state(k,:), C);

    OrbitHistory.a(k)           = elements(1);
    OrbitHistory.e(k)           = elements(2);
    OrbitHistory.i(k)           = rad2deg(elements(3));
    OrbitHistory.raan(k)        = rad2deg(elements(4));
    OrbitHistory.argPerigee(k)  = rad2deg(elements(5));
    OrbitHistory.trueAnomaly(k) = rad2deg(elements(6));

    r = Trajectory.state(k,1:3);
    OrbitHistory.height(k) = norm(r) - C.Re;

end

end