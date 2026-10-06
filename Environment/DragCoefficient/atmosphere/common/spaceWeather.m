function [f107,f107a,ap,kp] = spaceWeather(userDateStr)
%SPACEWEATHER Retrieve space weather parameters for a given date.
%
% Input:
%   userDateStr - Date in 'yyyy-MM-dd' format.
%
% Output:
%   f107  - Daily F10.7 solar flux index
%   f107a - 81-day averaged F10.7 solar flux index
%   ap    - Daily geomagnetic Ap index
%   kp    - Planetary geomagnetic Kp index
%
% If the requested date is not present in the database,
% the values are linearly interpolated between the nearest
% available dates before and after the requested date.

    persistent T

    %% Load space weather database

    if isempty(T)

        currentFolder = fileparts(mfilename('fullpath'));
        weatherFile = fullfile(currentFolder,'space_weather.csv');

        if ~isfile(weatherFile)
            error('spaceWeather:FileNotFound', ...
                'Unable to find or open "%s".', weatherFile);
        end

        T = readtable(weatherFile);

        % Make sure DATE is datetime
        if ~isdatetime(T.DATE)
            T.DATE = datetime(T.DATE, ...
                'InputFormat','yyyy-MM-dd');
        end

        % Sort table by date
        T = sortrows(T,'DATE');

    end

    %% Convert requested date

    d = datetime(userDateStr,...
        'InputFormat','yyyy-MM-dd');

    %% Find exact date

    idx = T.DATE == d;

    % ---------------------------------------------------------
    % If exact date exists, use values directly
    % ---------------------------------------------------------

    if any(idx)

        f107  = T.F10_7_OBS(idx);
        f107a = T.F10_7_OBS_LAST81(idx);

        ap = T.AP_AVG(idx);

        % Kp calculation used in the original code
        kp = T.KP_SUM(idx) / 80;

        return;
    end

    %% Date is missing
    %
    % Find nearest available dates before and after requested date

    idxBefore = find(T.DATE < d,1,'last');
    idxAfter  = find(T.DATE > d,1,'first');

    %% Check that interpolation is possible

    if isempty(idxBefore) || isempty(idxAfter)

        error('spaceWeather:DateOutOfRange', ...
            ['Date %s is outside the available range in ' ...
             'space_weather.csv.'], ...
             userDateStr);

    end

    %% Dates used for interpolation

    dateBefore = T.DATE(idxBefore);
    dateAfter  = T.DATE(idxAfter);

    %% Interpolation coefficient
    %
    % alpha = 0 -> dateBefore
    % alpha = 1 -> dateAfter

    alpha = days(d - dateBefore) / ...
            days(dateAfter - dateBefore);

    %% Get values before and after requested date

    % F10.7
    f107_before = T.F10_7_OBS(idxBefore);
    f107_after  = T.F10_7_OBS(idxAfter);

    % 81-day average F10.7
    f107a_before = T.F10_7_OBS_LAST81(idxBefore);
    f107a_after  = T.F10_7_OBS_LAST81(idxAfter);

    % Daily Ap
    ap_before = T.AP_AVG(idxBefore);
    ap_after  = T.AP_AVG(idxAfter);

    % Daily Kp
    kp_before = T.KP_SUM(idxBefore) / 80;
    kp_after  = T.KP_SUM(idxAfter) / 80;

    %% Linear interpolation

    f107 = f107_before + ...
        alpha * (f107_after - f107_before);

    f107a = f107a_before + ...
        alpha * (f107a_after - f107a_before);

    ap = ap_before + ...
        alpha * (ap_after - ap_before);

    kp = kp_before + ...
        alpha * (kp_after - kp_before);

end

