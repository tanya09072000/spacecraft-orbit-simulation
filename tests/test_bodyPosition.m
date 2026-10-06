function test_bodyPosition()
%TEST_BODYPOSITION Test SPICE body position function.

clear
clc

projectRoot = fileparts(mfilename('fullpath'));
addpath(genpath(projectRoot));

kernelDir = fullfile(projectRoot, 'Ephemerides', 'kernels');

cspice_furnsh(fullfile(kernelDir, 'naif0012.tls'));
cspice_furnsh(fullfile(kernelDir, 'de440.bsp'));

currentDate = datetime(2026,5,1,4,38,11);

rSun  = bodyPosition('SUN', currentDate);
rMoon = bodyPosition('MOON', currentDate);

fprintf('Sun position [km]:\n');
disp(rSun)

fprintf('Distance to Sun = %.3f million km\n\n', norm(rSun)/1e6);

fprintf('Moon position [km]:\n');
disp(rMoon)

fprintf('Distance to Moon = %.0f km\n', norm(rMoon));
end