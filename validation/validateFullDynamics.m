function passed = validateFullDynamics(Trajectory, Data, C)
%VALIDATEFULLDYNAMICS Validate total acceleration model.
%
% Compares the sum of all individual acceleration components
% with the acceleration returned by orbitalDynamics().

%% Select validation point

k = round(size(Trajectory.state,1) / 2);

t = Trajectory.time(k);
y = Trajectory.state(k,:)';

r = y(1:3);
v = y(4:6);

%% Individual acceleration components

aCentral = gravity(r, C);

aJ2 = zeros(3,1);
aDrag = zeros(3,1);
aSRP = zeros(3,1);
aSun = zeros(3,1);
aMoon = zeros(3,1);

if Data.Model.J2

    aJ2 = gravityJ2(r, C);

end

if Data.Model.drag

    aDrag = drag(t, r, v, Data, C);

end

if Data.Model.SRP

    aSRP = solarRadiationPressure( ...
        t, r, Data, C);

end

if Data.Model.sun

    aSun = sunGravity( ...
        t, r, Data, C);

end

if Data.Model.moon

    aMoon = moonGravity( ...
        t, r, Data, C);

end

%% Sum of individual components

aSum = ...
    aCentral + ...
    aJ2 + ...
    aDrag + ...
    aSRP + ...
    aSun + ...
    aMoon;

%% Acceleration from production dynamics

dy = orbitalDynamics(t, y, C, Data);

aModel = dy(4:6);

%% Difference

deltaA = aModel - aSum;

relativeError = ...
    norm(deltaA) / norm(aModel) * 100;

%% Output

fprintf('\n');
fprintf('=====================================================\n');
fprintf('             FULL DYNAMICS VALIDATION\n');
fprintf('=====================================================\n');

fprintf('\nValidation point\n');
fprintf('-----------------------------------------------------\n');

fprintf('Time               : %.3f h\n', ...
    t / 3600);

fprintf('\nAcceleration components\n');
fprintf('-----------------------------------------------------\n');

fprintf('Central gravity    : %.6e km/s^2\n', ...
    norm(aCentral));

fprintf('J2                 : %.6e km/s^2\n', ...
    norm(aJ2));

fprintf('Atmospheric drag   : %.6e km/s^2\n', ...
    norm(aDrag));

fprintf('Solar radiation    : %.6e km/s^2\n', ...
    norm(aSRP));

fprintf('Sun gravity        : %.6e km/s^2\n', ...
    norm(aSun));

fprintf('Moon gravity       : %.6e km/s^2\n', ...
    norm(aMoon));

fprintf('\nTotal acceleration\n');
fprintf('-----------------------------------------------------\n');

fprintf('Sum of components  : %.12e km/s^2\n', ...
    norm(aSum));

fprintf('Model acceleration  : %.12e km/s^2\n', ...
    norm(aModel));

fprintf('Difference         : %.6e km/s^2\n', ...
    norm(deltaA));

fprintf('Relative error     : %.6e %%\n', ...
    relativeError);

fprintf('\n');

%% Validation result

passed = relativeError < 1e-10;

if passed

    fprintf('Result             : PASS\n');

else

    fprintf('Result             : FAIL\n');

end


fprintf('\n');
fprintf('=====================================================\n');

end