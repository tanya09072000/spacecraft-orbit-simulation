function passed = validateMoonGravity(Trajectory, Data, C)
%VALIDATEMOONGRAVITY Validate lunar third-body gravitational acceleration.
%
% Compares the lunar gravitational acceleration calculated by the
% production moonGravity() function with an independent calculation.

%% Select validation point

k = round(size(Trajectory.state, 1) / 2);

t = Trajectory.time(k);

r = Trajectory.state(k,1:3)';

%% Current epoch

currentDate = ...
    Data.Scenario.separationTime + seconds(t);

%% Moon position

rMoon = bodyPosition('MOON', currentDate);

%% Production model

aModel = moonGravity( ...
    t, ...
    r, ...
    Data, ...
    C);

%% Independent third-body calculation

rRel = rMoon - r;

dRel = norm(rRel);
dMoon = norm(rMoon);

aReference = C.muMoon * ...
    ( ...
        rRel / dRel^3 ...
        - rMoon / dMoon^3 ...
    );

%% Difference

deltaA = aModel - aReference;

relativeError = ...
    norm(deltaA) / norm(aReference) * 100;

%% Output

fprintf('\n');
fprintf('=====================================================\n');
fprintf('             MOON GRAVITY VALIDATION\n');
fprintf('=====================================================\n');

fprintf('\nValidation point\n');
fprintf('-----------------------------------------------------\n');

fprintf('Time               : %.3f h\n', ...
    t / 3600);

fprintf('Date               : %s\n', ...
    datestr(currentDate));

fprintf('Moon distance      : %.6e km\n', ...
    norm(rMoon));

fprintf('Spacecraft-Moon    : %.6e km\n', ...
    dRel);

fprintf('\nMoon gravitational acceleration\n');
fprintf('-----------------------------------------------------\n');

fprintf('Reference |aMoon|  : %.6e km/s^2\n', ...
    norm(aReference));

fprintf('Model     |aMoon|  : %.6e km/s^2\n', ...
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