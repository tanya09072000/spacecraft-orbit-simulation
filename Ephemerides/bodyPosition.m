function rBody = bodyPosition(bodyName, timeInput)
%BODYPOSITION Return the position of a Solar System body
% relative to the Earth in the J2000 inertial frame.
%
% timeInput:
%   datetime - UTC date
%   numeric  - SPICE ephemeris time [s]

%% Convert input time to SPICE ET

if isdatetime(timeInput)

    utcStr = datestr(timeInput, ...
        'yyyy-mm-ddTHH:MM:SS.FFF');

    et = cspice_str2et(utcStr);

elseif isnumeric(timeInput) && isscalar(timeInput)

    et = timeInput;

else

    error('timeInput must be a datetime or a numeric scalar ET.');

end

%% SPICE position

[rBody, ~] = cspice_spkpos( ...
    bodyName, ...
    et, ...
    'J2000', ...
    'NONE', ...
    'EARTH');

end