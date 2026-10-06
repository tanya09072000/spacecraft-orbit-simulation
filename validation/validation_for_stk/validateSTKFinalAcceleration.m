function validateSTKFinalAcceleration(Data, C)

%VALIDATESTKFINALACCELERATION
% Compares MATLAB perturbation accelerations with STK
% at the same Cartesian state and epoch.

fprintf('\n');
fprintf('=====================================================\n');
fprintf('       MATLAB / STK FINAL ACCELERATION TEST\n');
fprintf('=====================================================\n');

%% STK final state

epoch = datetime(2026,5,8,4,38,11);

t = seconds(epoch - Data.Scenario.separationTime);

r = [ ...
    -63.398284;
     892.569052;
    -6804.578994 ];

v = [ ...
     7.559300;
     0.920947;
     0.056278 ];

fprintf('\nEpoch\n');
fprintf('-----------------------------------------------------\n');
fprintf('%s UTC\n', ...
    datestr(epoch,'dd-mmm-yyyy HH:MM:SS.FFF'));

fprintf('\nTime since separation\n');
fprintf('-----------------------------------------------------\n');
fprintf('%.6f h\n', t/3600);

fprintf('\nSTK state used for validation\n');
fprintf('-----------------------------------------------------\n');

fprintf('x  = %.9f km\n',r(1));
fprintf('y  = %.9f km\n',r(2));
fprintf('z  = %.9f km\n',r(3));

fprintf('vx = %.9f km/s\n',v(1));
fprintf('vy = %.9f km/s\n',v(2));
fprintf('vz = %.9f km/s\n',v(3));

%% Individual accelerations

aCentral = gravity(r,C);

aJ2 = zeros(3,1);
aDrag = zeros(3,1);
aSRP = zeros(3,1);
aSun = zeros(3,1);
aMoon = zeros(3,1);

if Data.Model.J2
    aJ2 = gravityJ2(r,C);
end

if Data.Model.drag
    aDrag = drag(t,r,v,Data,C);
end

if Data.Model.SRP
    aSRP = solarRadiationPressure(t,r,Data,C);
end

if Data.Model.sun
    aSun = sunGravity(t,r,Data,C);
end

if Data.Model.moon
    aMoon = moonGravity(t,r,Data,C);
end

%% Total

aTotal = aCentral + ...
         aJ2 + ...
         aDrag + ...
         aSRP + ...
         aSun + ...
         aMoon;

%% Print

fprintf('\n');
fprintf('PERTURBATION ACCELERATION BREAKDOWN\n');
fprintf('=====================================================\n');

printAcceleration('CENTRAL GRAVITY',aCentral);
printAcceleration('J2',aJ2);
printAcceleration('ATMOSPHERIC DRAG',aDrag);
printAcceleration('SOLAR RADIATION PRESSURE',aSRP);
printAcceleration('SUN GRAVITY',aSun);
printAcceleration('MOON GRAVITY',aMoon);

printAcceleration('TOTAL ACCELERATION',aTotal);

fprintf('\n');
fprintf('=====================================================\n');

end


function printAcceleration(name,a)

fprintf('\n%s\n',name);
fprintf('-----------------------------------------------------\n');

fprintf('Ax = %.12e km/s^2\n',a(1));
fprintf('Ay = %.12e km/s^2\n',a(2));
fprintf('Az = %.12e km/s^2\n',a(3));

fprintf('|a| = %.12e km/s^2\n',norm(a));

end