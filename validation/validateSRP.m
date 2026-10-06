function passed = validateSRP(Trajectory, Data, C)
%VALIDATESRP Validate solar radiation pressure acceleration.
%
% Compares the SRP acceleration calculated by the production
% solarRadiationPressure() function with an independent calculation.

%% Select validation point

k = round(size(Trajectory.state, 1) / 2);

t = Trajectory.time(k);

r = Trajectory.state(k, 1:3)';

%% Current epoch

currentDate = ...
    Data.Scenario.separationTime + seconds(t);

%% Sun position

rSun = bodyPosition('SUN', currentDate);

%% Shadow condition

inShadow = isInShadow(r, rSun, C);

%% SRP acceleration from model

aModel = solarRadiationPressure( ...
    t, r, Data, C);

%% Independent calculation

if inShadow

    aReference = zeros(3,1);

else

    %% Vector from Sun to spacecraft

    rSunSat = r - rSun;

    %% Distance Sun-spacecraft [m]

    dSun = norm(rSunSat) * 1000;

    %% Direction of solar radiation

    sHat = rSunSat / norm(rSunSat);

    %% Solar radiation pressure [N/m^2]

    P = C.Psr * ...
        (C.AU / dSun)^2;

    %% SRP acceleration [m/s^2]

    aReferenceSI = ...
        P * ...
        Data.Spacecraft.Cr * ...
        (Data.Spacecraft.area / ...
         Data.Spacecraft.mass) * ...
        sHat;

    %% Convert to km/s^2

    aReference = aReferenceSI / 1000;

end

%% Difference

deltaA = aModel - aReference;

if norm(aReference) > 0

    relativeError = ...
        norm(deltaA) / norm(aReference) * 100;

else

    relativeError = 0;

end

%% Output

fprintf('\n');
fprintf('=====================================================\n');
fprintf('                  SRP VALIDATION\n');
fprintf('=====================================================\n');

fprintf('\nValidation point\n');
fprintf('-----------------------------------------------------\n');

fprintf('Time               : %.3f h\n', ...
    t / 3600);

fprintf('Date               : %s\n', ...
    datestr(currentDate));

fprintf('Sun distance       : %.6e km\n', ...
    norm(rSunSat));

fprintf('Earth shadow       : %s\n', ...
    string(inShadow));

fprintf('\nSolar radiation pressure\n');
fprintf('-----------------------------------------------------\n');

if ~inShadow

    fprintf('Pressure           : %.6e N/m^2\n', P);

end

fprintf('\nSRP acceleration\n');
fprintf('-----------------------------------------------------\n');

fprintf('Reference |aSRP|   : %.6e km/s^2\n', ...
    norm(aReference));

fprintf('Model     |aSRP|   : %.6e km/s^2\n', ...
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