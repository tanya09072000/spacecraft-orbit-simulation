clear;
clc;

C = orbConstants();

% STK J2000 state at 08-May-2026 03:38:11
clc;
clear;

r_eci = [ ...
    6708.917667;
    -187.792698;
    1435.142732];

r_stk = [ ...
    1371.760805;
    6566.073643;
    1452.386391];

current_dt = datetime(2026,5,8,3,38,11);

J2000 = datetime(2000,1,1,12,0,0);

days = seconds(current_dt - J2000) / 86400;

T = days / 36525;

GMST_deg = ...
    280.46061837 + ...
    360.98564736629 * days + ...
    0.000387933 * T^2 - ...
    T^3 / 38710000;

theta_matlab = deg2rad(mod(GMST_deg,360));

R3 = [ ...
     cos(theta_matlab)   sin(theta_matlab)  0;
    -sin(theta_matlab)   cos(theta_matlab)  0;
     0                   0                  1];

r_matlab = R3 * r_eci;

fprintf('\n===== COMPARISON =====\n');

fprintf('MATLAB ECEF:\n');
fprintf('X = %.9f km\n',r_matlab(1));
fprintf('Y = %.9f km\n',r_matlab(2));
fprintf('Z = %.9f km\n',r_matlab(3));

fprintf('\nSTK Fixed:\n');
fprintf('X = %.9f km\n',r_stk(1));
fprintf('Y = %.9f km\n',r_stk(2));
fprintf('Z = %.9f km\n',r_stk(3));

fprintf('\nDifference:\n');
fprintf('dX = %.9f km\n',r_matlab(1)-r_stk(1));
fprintf('dY = %.9f km\n',r_matlab(2)-r_stk(2));
fprintf('dZ = %.9f km\n',r_matlab(3)-r_stk(3));

fprintf('\nRotation angle:\n');
fprintf('MATLAB = %.12f deg\n',rad2deg(theta_matlab));

theta_stk = atan2( ...
    r_eci(1)*r_stk(2) - r_eci(2)*r_stk(1), ...
    r_eci(1)*r_stk(1) + r_eci(2)*r_stk(2));

fprintf('STK    = %.12f deg\n',rad2deg(theta_stk));

fprintf('Diff   = %.12f deg\n', ...
    rad2deg(theta_stk-theta_matlab));