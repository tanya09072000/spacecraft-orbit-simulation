function testNRLMSISE_STK()

%TESTNRLMSISE_STK
% Test NRLMSISE-00 at the STK validation point.

%% STK control point

current_dt = datetime( ...
    2026,5,4,16,58,38.600);

h = 505.077113;      % km
lat = -18.245;       % deg
lon = 60.646;        % deg

%% Run NRLMSISE

Atmosphere = nrlWrapper( ...
    h, ...
    current_dt, ...
    lat, ...
    lon);

%% Output

fprintf('\n');
fprintf('=====================================================\n');
fprintf('          NRLMSISE STK CONTROL POINT\n');
fprintf('=====================================================\n');

fprintf('\nInput\n');
fprintf('-----------------------------------------------------\n');

fprintf('Epoch      : %s UTC\n', ...
    datestr(current_dt,'dd-mmm-yyyy HH:MM:SS.FFF'));

fprintf('Altitude   : %.6f km\n', h);
fprintf('Latitude   : %.6f deg\n', lat);
fprintf('Longitude  : %.6f deg\n', lon);

fprintf('\nNRLMSISE\n');
fprintf('-----------------------------------------------------\n');

fprintf('Density    : %.12e kg/m^3\n', ...
    Atmosphere.density);

fprintf('Tinf       : %.6f K\n', ...
    Atmosphere.temperature.exospheric);

fprintf('Tlocal     : %.6f K\n', ...
    Atmosphere.temperature.local);

fprintf('AMMW       : %.12f amu\n', ...
    Atmosphere.meanMolecularMass);

fprintf('\n');
fprintf('=====================================================\n');

end