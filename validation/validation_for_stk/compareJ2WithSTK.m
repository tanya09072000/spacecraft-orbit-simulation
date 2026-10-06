function compareJ2WithSTK(Trajectory, Data, C)
%COMPAREJ2WITHSTK Compare MATLAB J2 propagation with STK.
%
% Compares:
%   1. Analytical J2 RAAN drift rate
%   2. MATLAB numerical RAAN drift rate
%   3. STK numerical RAAN drift rate
%   4. MATLAB - STK RAAN difference
%
% Input:
%   Trajectory - MATLAB propagated trajectory
%   Data       - Simulation input data
%   C          - Physical constants

%% =====================================================
%              J2 VALIDATION — MATLAB vs STK
% ======================================================

%% Load STK data

STK = readtable( ...
    'KOEN Classical Orbit Elements.csv', ...
    'VariableNamingRule', 'preserve');


%% =====================================================
%                  STK TIME
% ======================================================

timeSTK = datetime( ...
    STK.("Time (UTCG)"), ...
    'InputFormat', 'd MMM yyyy HH:mm:ss.SSS');

% Time from separation epoch [days]

timeSTK_days = hours( ...
    timeSTK - Data.Scenario.separationTime) / 24;


%% =====================================================
%                  STK RAAN
% ======================================================

raanSTK = STK.("RAAN (deg)");

% Unwrap RAAN in case it crosses 360 deg

raanSTK_unwrapped = rad2deg( ...
    unwrap(deg2rad(raanSTK)));


%% =====================================================
%                MATLAB RAAN
% ======================================================

nPoints = size(Trajectory.state, 1);

raanMATLAB = zeros(nPoints, 1);

for k = 1:nPoints

    elements = stateVectorToOrbitalElements( ...
        Trajectory.state(k,:), C);

    raanMATLAB(k) = rad2deg(elements(4));

end


% Unwrap MATLAB RAAN

raanMATLAB_unwrapped = rad2deg( ...
    unwrap(deg2rad(raanMATLAB)));

% MATLAB time from separation epoch [days]

timeMATLAB_days = ...
    Trajectory.time / 86400;


%% =====================================================
%             LINEAR RAAN TRENDS
% ======================================================

% MATLAB

fitMATLAB = polyfit( ...
    timeMATLAB_days, ...
    raanMATLAB_unwrapped, ...
    1);

raanRateMATLAB = fitMATLAB(1);


% STK

fitSTK = polyfit( ...
    timeSTK_days, ...
    raanSTK_unwrapped, ...
    1);

raanRateSTK = fitSTK(1);


%% =====================================================
%            ANALYTICAL J2 RAAN RATE
% ======================================================

a0 = Data.Orbit.a;
e0 = Data.Orbit.e;
i0 = deg2rad(Data.Orbit.i);

p0 = a0 * (1 - e0^2);

n0 = sqrt(C.mu / a0^3);

raanRateAnalytical = ...
    -3/2 * C.J2 * ...
    (C.Re / p0)^2 * ...
    n0 * cos(i0);

raanRateAnalyticalDegDay = ...
    rad2deg(raanRateAnalytical) * 86400;


%% =====================================================
%                  DISPLAY RATES
% ======================================================

fprintf('\n');
fprintf('=====================================================\n');
fprintf('             J2 RAAN COMPARISON\n');
fprintf('=====================================================\n');

fprintf('\nRAAN drift rate\n');
fprintf('-----------------------------------------------------\n');

fprintf('Analytical          : %.6f deg/day\n', ...
    raanRateAnalyticalDegDay);

fprintf('MATLAB              : %.6f deg/day\n', ...
    raanRateMATLAB);

fprintf('STK                 : %.6f deg/day\n', ...
    raanRateSTK);

fprintf('\nMATLAB - Analytical  : %.6f deg/day\n', ...
    raanRateMATLAB - raanRateAnalyticalDegDay);

fprintf('STK - Analytical     : %.6f deg/day\n', ...
    raanRateSTK - raanRateAnalyticalDegDay);

fprintf('MATLAB - STK         : %.6f deg/day\n', ...
    raanRateMATLAB - raanRateSTK);

fprintf('\nRelative difference MATLAB-STK : %.6f %%\n', ...
    abs(raanRateMATLAB - raanRateSTK) / ...
    abs(raanRateSTK) * 100);


%% =====================================================
%                  PLOT RAAN
% ======================================================

figure;

plot( ...
    timeMATLAB_days, ...
    raanMATLAB_unwrapped, ...
    'LineWidth', 1.2);

hold on;

plot( ...
    timeSTK_days, ...
    raanSTK_unwrapped, ...
    '--', ...
    'LineWidth', 1.2);

grid on;

xlabel('Time [days]');
ylabel('RAAN [deg]');

title('J2 validation — RAAN drift');

legend( ...
    'MATLAB', ...
    'STK', ...
    'Location', 'best');


%% =====================================================
%          MATLAB - STK RAAN DIFFERENCE
% ======================================================

% Interpolate STK RAAN to MATLAB time points

raanSTK_interp = interp1( ...
    timeSTK_days, ...
    raanSTK_unwrapped, ...
    timeMATLAB_days, ...
    'linear');


% Difference

deltaRAAN = ...
    raanMATLAB_unwrapped - raanSTK_interp;


%% =====================================================
%          LINEAR TREND OF DIFFERENCE
% ======================================================

fitDelta = polyfit( ...
    timeMATLAB_days, ...
    deltaRAAN, ...
    1);

deltaTrend = polyval( ...
    fitDelta, ...
    timeMATLAB_days);

deltaRate = fitDelta(1);


%% =====================================================
%              DIFFERENCE STATISTICS
% ======================================================

initialDifference = deltaRAAN(1);
finalDifference   = deltaRAAN(end);

maximumDifference = ...
    max(abs(deltaRAAN));

meanDifference = ...
    mean(deltaRAAN);


fprintf('\n');
fprintf('=====================================================\n');
fprintf('              RAAN DIFFERENCE TREND\n');
fprintf('=====================================================\n');

fprintf('\nMATLAB - STK\n');
fprintf('-----------------------------------------------------\n');

fprintf('Difference rate     : %.6f deg/day\n', ...
    deltaRate);

fprintf('Initial difference  : %.6f deg\n', ...
    initialDifference);

fprintf('Final difference    : %.6f deg\n', ...
    finalDifference);

fprintf('Maximum |difference|: %.6f deg\n', ...
    maximumDifference);

fprintf('Mean difference     : %.6f deg\n', ...
    meanDifference);


%% =====================================================
%              PLOT RAAN DIFFERENCE
% ======================================================

figure;

plot( ...
    timeMATLAB_days, ...
    deltaRAAN, ...
    'LineWidth', 0.5);

hold on;

plot( ...
    timeMATLAB_days, ...
    deltaTrend, ...
    '--', ...
    'LineWidth', 1.5);

yline(0, ':');

grid on;

xlabel('Time [days]');
ylabel('\Delta RAAN [deg]');

title('J2 validation — MATLAB - STK RAAN difference');

legend( ...
    'MATLAB - STK', ...
    'Linear trend', ...
    'Location', 'best');


%% =====================================================
%              FINAL COMPARISON RESULT
% ======================================================

fprintf('\n');
fprintf('=====================================================\n');
fprintf('              J2 STK COMPARISON RESULT\n');
fprintf('=====================================================\n');

fprintf('Analytical rate     : %.6f deg/day\n', ...
    raanRateAnalyticalDegDay);

fprintf('MATLAB rate         : %.6f deg/day\n', ...
    raanRateMATLAB);

fprintf('STK rate            : %.6f deg/day\n', ...
    raanRateSTK);

fprintf('MATLAB - STK rate   : %.6f deg/day\n', ...
    raanRateMATLAB - raanRateSTK);

fprintf('Maximum |Delta RAAN|: %.6f deg\n', ...
    maximumDifference);

fprintf('Final Delta RAAN    : %.6f deg\n', ...
    finalDifference);

fprintf('=====================================================\n'); 

end