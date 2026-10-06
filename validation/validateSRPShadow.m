function passed = validateSRPShadow(Trajectory, Data, C)
%VALIDATESRPSHADOW Validate SRP behavior in sunlight and Earth's shadow.
%
% Checks:
%   1. SRP acceleration is non-zero in sunlight.
%   2. SRP acceleration is zero in Earth's shadow.

%% Number of trajectory points

nPoints = size(Trajectory.state, 1);

%% Search for sunlight and shadow points

sunlightIndex = NaN;
shadowIndex = NaN;

for k = 1:nPoints

    t = Trajectory.time(k);

    r = Trajectory.state(k,1:3)';

    currentDate = ...
        Data.Scenario.separationTime + seconds(t);

    rSun = bodyPosition('SUN', currentDate);

    inShadow = isInShadow(r, rSun, C);

    if inShadow && isnan(shadowIndex)

        shadowIndex = k;

    elseif ~inShadow && isnan(sunlightIndex)

        sunlightIndex = k;

    end

    if ~isnan(sunlightIndex) && ...
       ~isnan(shadowIndex)

        break;

    end

end

%% Check that both cases were found

if isnan(sunlightIndex)

    error('No sunlight point was found in the trajectory.');

end

if isnan(shadowIndex)

    error('No shadow point was found in the trajectory.');

end

%% Sunlight test

tSun = Trajectory.time(sunlightIndex);

rSunlight = ...
    Trajectory.state(sunlightIndex,1:3)';

aSunlight = solarRadiationPressure( ...
    tSun, ...
    rSunlight, ...
    Data, ...
    C);

%% Shadow test

tShadow = Trajectory.time(shadowIndex);

rShadow = ...
    Trajectory.state(shadowIndex,1:3)';

aShadow = solarRadiationPressure( ...
    tShadow, ...
    rShadow, ...
    Data, ...
    C);

%% Results

fprintf('\n');
fprintf('=====================================================\n');
fprintf('                 SRP SHADOW VALIDATION\n');
fprintf('=====================================================\n');

%% Sunlight

fprintf('\nSunlight case\n');
fprintf('-----------------------------------------------------\n');

fprintf('Time               : %s\n', ...
    datestr( ...
        Data.Scenario.separationTime + seconds(tSun)));

fprintf('SRP acceleration   : %.6e km/s^2\n', ...
    norm(aSunlight));

if norm(aSunlight) > 0

    fprintf('Result             : PASS\n');

else

    fprintf('Result             : FAIL\n');

end

%% Shadow

fprintf('\nEarth shadow case\n');
fprintf('-----------------------------------------------------\n');

fprintf('Time               : %s\n', ...
    datestr( ...
        Data.Scenario.separationTime + seconds(tShadow)));

fprintf('SRP acceleration   : %.6e km/s^2\n', ...
    norm(aShadow));

if norm(aShadow) == 0

    fprintf('Result             : PASS\n');

else

    fprintf('Result             : FAIL\n');

end

sunlightPassed = norm(aSunlight) > 0;

shadowPassed = norm(aShadow) == 0;

passed = sunlightPassed && shadowPassed;

if passed

    fprintf('Overall result     : PASS\n');

else

    fprintf('Overall result     : FAIL\n');

end

fprintf('\n');
fprintf('=====================================================\n');

end