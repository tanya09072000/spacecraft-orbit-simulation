function  LTAN = calculateLTAN(time, raan, Data)

%CALCULATELTAN Calculate Local Time of Ascending Node.
%
% Computes the local solar time at which the spacecraft crosses the
% ascending node of the orbit.
%
% Input:
%   time - Time since separation [s]
%   raan - Right ascension of ascending node [deg]
%   Data - Simulation input data
%
% Output:
%   LTAN - Local Time of Ascending Node [hours]

%% Current UTC time

currentDate = Data.Scenario.separationTime + seconds(time);

%% Sun position in ECI

rSun = bodyPosition('SUN', currentDate);

%% Sun right ascension

alphaSun = atan2d(rSun(2), rSun(1));
alphaSun = mod(alphaSun,360);

%% Local time of ascending node
LTAN = 12 + (raan - alphaSun) / 15;

%% Convert to [0, 24) hours
LTAN = mod(LTAN, 24);

end
