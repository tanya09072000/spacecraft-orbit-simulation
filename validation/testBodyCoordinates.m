function testBodyCoordinates(rSC, currentDate)
%TESTBODYCOORDINATES Check Sun and Moon coordinates from SPICE.
%
% rSC        - spacecraft position in ECI/J2000 [km]
% currentDate - UTC datetime

fprintf('\n');
fprintf('=====================================================\n');
fprintf('       SUN / MOON COORDINATE SYSTEM TEST\n');
fprintf('=====================================================\n');

fprintf('\nEpoch\n');
fprintf('-----------------------------------------------------\n');
fprintf('%s UTC\n', ...
    datestr(currentDate,'dd-mmm-yyyy HH:MM:SS.FFF'));

%% Spacecraft

fprintf('\nSPACECRAFT\n');
fprintf('-----------------------------------------------------\n');

fprintf('X = %.12f km\n', rSC(1));
fprintf('Y = %.12f km\n', rSC(2));
fprintf('Z = %.12f km\n', rSC(3));
fprintf('|rSC| = %.12f km\n', norm(rSC));

%% Sun

rSun = bodyPosition('SUN', currentDate);

fprintf('\nSUN\n');
fprintf('-----------------------------------------------------\n');

fprintf('Frame  : J2000\n');
fprintf('Center : EARTH\n');

fprintf('X = %.12f km\n', rSun(1));
fprintf('Y = %.12f km\n', rSun(2));
fprintf('Z = %.12f km\n', rSun(3));

fprintf('|rSun| = %.12f km\n', norm(rSun));

%% Moon

rMoon = bodyPosition('MOON', currentDate);

fprintf('\nMOON\n');
fprintf('-----------------------------------------------------\n');

fprintf('Frame  : J2000\n');
fprintf('Center : EARTH\n');

fprintf('X = %.12f km\n', rMoon(1));
fprintf('Y = %.12f km\n', rMoon(2));
fprintf('Z = %.12f km\n', rMoon(3));

fprintf('|rMoon| = %.12f km\n', norm(rMoon));

fprintf('\n');
fprintf('=====================================================\n');

end