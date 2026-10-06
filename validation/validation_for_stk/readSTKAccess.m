function STK = readSTKAccess(filename)
%READSTKACCESS Read STK Access report.
%
% Input:
%   filename - path to STK Access CSV file
%
% Output:
%   STK.sessions - structure array containing:
%       startTime
%       endTime
%       duration
%
% Expected STK format:
%
% Access, Start Time (UTCG), Stop Time (UTCG), Duration (sec)
% 1, 1 May 2026 04:57:27.121, 1 May 2026 05:01:23.970, 236.849
% 2, 1 May 2026 14:30:53.339, 1 May 2026 14:36:37.387, 344.048

%% Read file

fid = fopen(filename, 'r');

if fid == -1
    error('Cannot open STK file: %s', filename);
end

%% Skip header

fgetl(fid);

%% Initialize

sessions = struct( ...
    'startTime', {}, ...
    'endTime', {}, ...
    'duration', {});

%% Date format used by STK

dateFormat = 'd MMM yyyy HH:mm:ss.SSS';

%% Read all lines

k = 0;

while ~feof(fid)

    line = strtrim(fgetl(fid));

    if isempty(line)
        continue;
    end

    %% Parse line

    parts = split(line, ',');

    if numel(parts) < 4
        warning('Skipping invalid line:\n%s', line);
        continue;
    end

    %% Session number

    sessionNumber = str2double(strtrim(parts{1}));

    %% Start time

    startString = strtrim(parts{2});

    %% End time

    endString = strtrim(parts{3});

    %% Duration

    duration = str2double(strtrim(parts{4}));

    %% Check values

    if isnan(sessionNumber) || ...
       isnan(duration)

        warning('Skipping invalid line:\n%s', line);
        continue;
    end

    %% Convert times

    startTime = datetime( ...
        startString, ...
        'InputFormat', dateFormat, ...
        'Locale', 'en_US', ...
        'TimeZone', 'UTC');

    endTime = datetime( ...
        endString, ...
        'InputFormat', dateFormat, ...
        'Locale', 'en_US', ...
        'TimeZone', 'UTC');

    %% Save session

    k = k + 1;

    sessions(k).startTime = startTime;
    sessions(k).endTime = endTime;
    sessions(k).duration = duration;

end

%% Close file

fclose(fid);

%% Output

STK.sessions = sessions;

STK.filename = filename;

STK.nSessions = length(sessions);

end