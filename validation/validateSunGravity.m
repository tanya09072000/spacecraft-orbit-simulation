function passed = validateSunGravity(Trajectory, Data, C)
%VALIDATESUNGRAVITY Validate solar third-body gravitational acceleration.
%
% Compares the solar gravitational acceleration calculated by the
% production sunGravity() function with an independent calculation.

%% Select validation point

k = round(size(Trajectory.state, 1) / 2);

t = Trajectory.time(k);

r = Trajectory.state(k,1:3)';

%% Current epoch

currentDate = ...
    Data.Scenario.separationTime + seconds(t);

%% Sun position

rSun = bodyPosition('SUN', currentDate);

%% Production model

aModel = sunGravity( ...
    t, ...
    r, ...
    Data, ...
    C);

%% Independent third-body calculation

rRel = rSun - r;

dRel = norm(rRel);
dSun = norm(rSun);

aReference = C.muSun * ...
    ( ...
        rRel / dRel^3 ...
        - rSun / dSun^3 ...
    );

%% Difference

deltaA = aModel - aReference;

relativeError = ...
    norm(deltaA) / norm(aReference) * 100;

%% Output

fprintf('\n');
fprintf('=====================================================\n');
fprintf('              SUN GRAVITY VALIDATION\n');
fprintf('=====================================================\n');

fprintf('\nValidation point\n');
fprintf('-----------------------------------------------------\n');

fprintf('Time               : %.3f h\n', ...
    t / 3600);

fprintf('Date               : %s\n', ...
    datestr(currentDate));

fprintf('Sun distance       : %.6e km\n', ...
    dSun);

fprintf('Spacecraft-Sun     : %.6e km\n', ...
    dRel);

fprintf('\nSolar gravitational acceleration\n');
fprintf('-----------------------------------------------------\n');

fprintf('Reference |aSun|   : %.6e km/s^2\n', ...
    norm(aReference));

fprintf('Model     |aSun|   : %.6e km/s^2\n', ...
    norm(aModel));

fprintf('Difference         : %.6e km/s^2\n', ...
    norm(deltaA));

fprintf('Relative error     : %.6e %%\n', ...
    relativeError);

passed = relativeError < 1e-10;

if passed

    fprintf('Result             : PASS\n');

else

    fprintf('Result             : FAIL\n');

end

fprintf('\n');
fprintf('=====================================================\n');

end