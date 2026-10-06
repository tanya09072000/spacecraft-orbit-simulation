function Result = validateVisibility(STK, MATLAB, tolerance)
%VALIDATEVISIBILITY Compare MATLAB visibility sessions with STK.
%
% Input:
%   STK       - STK visibility sessions
%   MATLAB    - MATLAB visibility sessions
%   tolerance - Allowed absolute time error [s]
%
% Output:
%   Result    - Validation results
%
% Compared parameters:
%   - Session start time
%   - Session end time
%   - Session duration
%
% The function calculates:
%   - Mean absolute error
%   - Maximum absolute error
%   - RMS error
%   - Relative duration error
%   - PASS / FAIL status

%% Check number of sessions

nSTK = length(STK);
nMAT = length(MATLAB);

Result.nSTK = nSTK;
Result.nMATLAB = nMAT;

if nSTK ~= nMAT

    Result.status = false;

    error( ...
        'Number of sessions differs: STK = %d, MATLAB = %d.', ...
        nSTK, nMAT);

end

nSessions = nSTK;

%% Initialize errors

startError = zeros(nSessions,1);
endError   = zeros(nSessions,1);
durationError = zeros(nSessions,1);
relativeDurationError = zeros(nSessions,1);

%% Compare sessions

for k = 1:nSessions

    %% Start time error

    startError(k) = seconds( ...
        MATLAB(k).startTime - STK(k).startTime);

    %% End time error

    endError(k) = seconds( ...
        MATLAB(k).endTime - STK(k).endTime);

    %% Duration error

    durationError(k) = ...
        MATLAB(k).duration - STK(k).duration;

    %% Relative duration error

    relativeDurationError(k) = ...
        100 * durationError(k) / STK(k).duration;

end

%% Absolute errors

absStartError = abs(startError);
absEndError = abs(endError);
absDurationError = abs(durationError);
absRelativeDurationError = abs(relativeDurationError);

%% Statistics

Result.start.meanAbsolute = mean(absStartError);
Result.start.maxAbsolute = max(absStartError);
Result.start.RMS = sqrt(mean(startError.^2));

Result.end.meanAbsolute = mean(absEndError);
Result.end.maxAbsolute = max(absEndError);
Result.end.RMS = sqrt(mean(endError.^2));

Result.duration.meanAbsolute = mean(absDurationError);
Result.duration.maxAbsolute = max(absDurationError);
Result.duration.RMS = sqrt(mean(durationError.^2));

Result.duration.meanRelative = ...
    mean(absRelativeDurationError);

Result.duration.maxRelative = ...
    max(absRelativeDurationError);

%% Save individual errors

Result.startError = startError;
Result.endError = endError;
Result.durationError = durationError;
Result.relativeDurationError = relativeDurationError;

%% Validation criteria

Result.tolerance = tolerance;

Result.start.pass = ...
    all(absStartError <= tolerance);

Result.end.pass = ...
    all(absEndError <= tolerance);

Result.duration.pass = ...
    all(absDurationError <= tolerance);

%% Overall status

Result.status = ...
    Result.start.pass && ...
    Result.end.pass && ...
    Result.duration.pass;

end