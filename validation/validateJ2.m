function passed = validateJ2(Trajectory, Data, C)
%VALIDATEJ2 Validate J2 perturbation model.
%
% Checks:
%   1. Secular RAAN drift
%   2. Secular argument of perigee drift
%   3. Semi-major axis short-period variations
%   4. Specific mechanical energy conservation

%% Initial orbital elements

elements0 = stateVectorToOrbitalElements( ...
    Trajectory.state(1,:), C);

a = elements0(1);
e = elements0(2);
i = elements0(3);

%% J2 parameters

J2 = C.J2;
Re = C.Re;
mu = C.mu;

%% Auxiliary parameters

p = a * (1 - e^2);

n = sqrt(mu / a^3);

%% Analytical J2 RAAN drift

raanRate = ...
    -3/2 * J2 * (Re/p)^2 * n * cos(i);

raanRateDegDay = ...
    rad2deg(raanRate) * 86400;

%% Analytical J2 argument of perigee drift

argPerigeeRate = ...
    3/4 * J2 * (Re/p)^2 * n * ...
    (5*cos(i)^2 - 1);

argPerigeeRateDegDay = ...
    rad2deg(argPerigeeRate) * 86400;

%% Number of trajectory points

nPoints = size(Trajectory.state, 1);

%% Orbital element history

raanHistory = zeros(nPoints,1);
argHistory = zeros(nPoints,1);
aHistory = zeros(nPoints,1);

for k = 1:nPoints

    elements = stateVectorToOrbitalElements( ...
        Trajectory.state(k,:), C);

    aHistory(k) = elements(1);
    raanHistory(k) = elements(4);
    argHistory(k) = elements(5);

end

%% Unwrap angles

raanHistory = unwrap(raanHistory);
argHistory = unwrap(argHistory);

%% Time

timeDays = Trajectory.time / 86400;

%% Numerical RAAN drift

fitRAAN = polyfit( ...
    timeDays, ...
    rad2deg(raanHistory), ...
    1);

raanRateNumericalDegDay = fitRAAN(1);

%% RAAN validation

raanDifference = ...
    raanRateNumericalDegDay - raanRateDegDay;

raanRelativeError = ...
    raanDifference / raanRateDegDay * 100;

%% Numerical argument of perigee drift

fitArg = polyfit( ...
    timeDays, ...
    rad2deg(argHistory), ...
    1);

argRateNumericalDegDay = fitArg(1);

%% Argument of perigee validation

argDifference = ...
    argRateNumericalDegDay - argPerigeeRateDegDay;

argRelativeError = ...
    argDifference / argPerigeeRateDegDay * 100;

%% Semi-major axis variation

deltaA = aHistory - aHistory(1);

%% Specific mechanical energy

energy = zeros(nPoints,1);

for k = 1:nPoints

    r = Trajectory.state(k,1:3)';
    v = Trajectory.state(k,4:6)';

    rNorm = norm(r);
    vNorm = norm(v);

    % Geocentric latitude

    sinPhi = r(3) / rNorm;

    % Second Legendre polynomial

    P2 = 0.5 * (3*sinPhi^2 - 1);

    % Central gravitational potential

    U0 = -C.mu / rNorm;

    % J2 gravitational potential

    UJ2 = ...
        C.mu / rNorm * ...
        C.J2 * (C.Re / rNorm)^2 * P2;

    % Total specific mechanical energy

    energy(k) = ...
        0.5 * vNorm^2 + U0 + UJ2;

end

%% Energy conservation

energy0 = energy(1);

deltaEnergy = energy - energy0;

relativeEnergyError = ...
    deltaEnergy / abs(energy0);

maxEnergyError = ...
    max(abs(deltaEnergy));

maxRelativeEnergyError = ...
    max(abs(relativeEnergyError)) * 100;

%% Validation criteria

raanPassed = abs( ...
    raanRateNumericalDegDay - ...
    raanRateDegDay) < 0.02;

argPassed = abs(argDifference) < 0.05;

energyPassed = ...
    max(abs(relativeEnergyError)) * 100 < 1e-5;

passed = ...
    raanPassed && ...
    energyPassed;

%% Output

fprintf('\n');
fprintf('=====================================================\n');
fprintf('                    J2 VALIDATION\n');
fprintf('=====================================================\n');

%% RAAN

fprintf('\nRAAN drift\n');
fprintf('-----------------------------------------------------\n');

fprintf('Analytical rate    : %.6f deg/day\n', ...
    raanRateDegDay);

fprintf('Numerical rate     : %.6f deg/day\n', ...
    raanRateNumericalDegDay);

fprintf('Difference         : %.6f deg/day\n', ...
    raanDifference);

fprintf('Relative error     : %.6f %%\n', ...
    raanRelativeError);

fprintf('Result             : %s\n', ...
    validationStatus(raanPassed));

%% Semi-major axis

fprintf('\nSemi-major axis variation\n');
fprintf('-----------------------------------------------------\n');

fprintf('Initial a          : %.6f km\n', ...
    aHistory(1));

fprintf('Final a            : %.6f km\n', ...
    aHistory(end));

fprintf('Minimum a          : %.6f km\n', ...
    min(aHistory));

fprintf('Maximum a          : %.6f km\n', ...
    max(aHistory));

fprintf('Maximum deviation  : %.6f km\n', ...
    max(abs(deltaA)));

%% Energy

fprintf('\nEnergy conservation\n');
fprintf('-----------------------------------------------------\n');

fprintf('Initial energy       : %.12f km^2/s^2\n', ...
    energy0);

fprintf('Final energy         : %.12f km^2/s^2\n', ...
    energy(end));

fprintf('Maximum |delta E|    : %.6e km^2/s^2\n', ...
    maxEnergyError);

fprintf('Maximum relative err : %.6e %%\n', ...
    maxRelativeEnergyError);

fprintf('Result               : %s\n', ...
    validationStatus(energyPassed));

%% Argument of perigee

%% Argument of perigee

fprintf('\nArgument of perigee drift\n');
fprintf('-----------------------------------------------------\n');

fprintf('Analytical rate    : %.6f deg/day\n', ...
    argPerigeeRateDegDay);

fprintf('Numerical rate     : %.6f deg/day\n', ...
    argRateNumericalDegDay);

fprintf('Difference         : %.6f deg/day\n', ...
    argDifference);

fprintf('Relative error     : %.6f %%\n', ...
    argRelativeError);

if e < 0.01

    fprintf('\n');
    fprintf('Warning            : Argument of perigee is poorly defined\n');
    fprintf('                     for nearly circular orbit (e = %.6f).\n', e);
    fprintf('Result             : NOT USED FOR PASS/FAIL\n');

else

    fprintf('Result             : %s\n', ...
        validationStatus(argPassed));

end

%% Overall result

fprintf('\nJ2 validation result : %s\n', ...
    validationStatus(passed));

fprintf('\n');
fprintf('=====================================================\n');

%% Plots

figure;

plot( ...
    Trajectory.time / 3600, ...
    aHistory, ...
    'LineWidth', 1.0);

grid on;

xlabel('Time [h]');
ylabel('Semi-major axis [km]');

title('J2 validation — Semi-major axis');

figure;

plot( ...
    timeDays, ...
    rad2deg(argHistory), ...
    'LineWidth', 1.0);

hold on;

plot( ...
    timeDays, ...
    polyval(fitArg, timeDays), ...
    '--', ...
    'LineWidth', 1.2);

grid on;

xlabel('Time [days]');
ylabel('Argument of perigee [deg]');

title('J2 validation — Argument of perigee');

legend( ...
    'Numerical', ...
    'Linear trend', ...
    'Location', 'best');

figure;

plot( ...
    Trajectory.time / 3600, ...
    deltaEnergy, ...
    'LineWidth', 1.0);

grid on;

xlabel('Time [h]');
ylabel('\Delta E [km^2/s^2]');

title('J2 validation — Specific mechanical energy');

end