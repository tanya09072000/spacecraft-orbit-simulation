function atmosphere = nrlWrapper(H,current_dt,lat_deg,lon_deg)
%NRLWRAPPER Interface to the NRLMSISE-00 atmospheric model.
%
% Input:
%   altitude        - Geometric altitude [km]
%   currentDateTime - Simulation date and time
%   latitude        - Geodetic latitude [deg]
%   longitude       - Geodetic longitude [deg]
%
% Output:
%   atmosphere - Structure containing atmospheric properties:
%       .temperature.exospheric  Exospheric temperature [K]
%       .temperature.local       Local temperature [K]
%       .meanMolecularMass       Mean molecular mass [amu]
%       .density                 Atmospheric density [kg/m^3]
%       .model                   Atmospheric model identifier

%% Default coordinates

if nargin < 3
    lat_deg = 0;
    lon_deg = 0;
end

dateStr     = datestr(current_dt,'yyyy-mm-dd');
dateTimeStr = datestr(current_dt,'yyyy-mm-dd HH:MM:SS');

[f107,f107a,ap, kp] = spaceWeather(dateStr);

%% Python interface

currentFolder = fileparts(mfilename('fullpath'));

pythonScript = fullfile( ...
    currentFolder, ...
    'Python-NRLMSISE-00-master', ...
    'nrl_query.py');

altitudesStr = sprintf('%.0f,', H);
altitudesStr(end) = [];

cmd = sprintf( ...
    'python "%s" "%s" "%s" %.6f %.6f %.3f %.3f %.3f', ...
    pythonScript,...
    altitudesStr,...
    dateTimeStr,...
    lat_deg,...
    lon_deg,...
    f107,...
    f107a,...
    ap);

[status,out] = system(cmd);

if status ~= 0
    error(out)
end

res = jsondecode(out);

atmosphere.temperature.exospheric = res.tinf;
atmosphere.temperature.local = res.tlocal;

atmosphere.meanMolecularMass = res.ammw;
atmosphere.density = res.rho;
atmosphere.model             = "NRLMSISE00";

end