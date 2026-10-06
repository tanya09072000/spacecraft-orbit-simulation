function atmosphere = ciraMain(altitudeKm, dateString)
%CIRAMAIN Interface to the CIRA atmospheric model.
%
% Input:
%   altitudeKm - Geometric altitude [km]
%   dateString - Date in 'yyyy-MM-dd' format
%
% Output:
%   atmosphere - Structure containing atmospheric properties:
%       .temperature        [2x1] Temperature vector [K]
%       .meanMolecularMass  Mean molecular mass [amu]
%       .density            Atmospheric density [kg/m^3]
%       .model              Atmospheric model identifier

%% Space weather

[f107, f81, ~, kp] = spaceWeather(dateString);

%% Solar and geomagnetic activity parameters

GEO = [f107; f81; kp];

%% CIRA model parameters

ALSA = 0.0;
DESA = 0.0;

ALSO = 0.0;
DESO = pi / 2;

myDate = datetime(dateString, ...
    'InputFormat','yyyy-MM-dd');

RJDAYS = juliandate(myDate);

%% Evaluate CIRA model

[TEMP, AL10N, AMMW, RHO] = cira( ...
    altitudeKm, ALSA, DESA, ...
    ALSO, DESO, ...
    RJDAYS, GEO);

atmosphere.temperature       = TEMP;
atmosphere.meanMolecularMass = AMMW;
atmosphere.density           = RHO;
atmosphere.model             = "CIRA72";

end