function plotFirstContact(Contact, Data)
%PLOTFIRSTCONTACT Plot elevation profile of the first communication session.
%
% Input:
%   Contact - First communication session
%   Data    - Simulation input data

if ~Contact.visible
    return;
end

s = Contact.stationIndex;

%% Time window around the first communication session

window = minutes(10);

plotStart = Contact.startTime - window;
plotEnd   = Contact.endTime + window;

time = Contact.stationData(s).time;
elevation = Contact.stationData(s).elevation;

idx = time >= plotStart & time <= plotEnd;

%% Plot

figure;

plot( ...
    time(idx), ...
    elevation(idx), ...
    'LineWidth', 1.2);

hold on;

yline( ...
    Data.Station(s).minElevation, ...
    '--');

xline( ...
    Contact.startTime, ...
    '--');

xline( ...
    Contact.endTime, ...
    '--');

grid on;

xlabel('Time');
ylabel('Elevation angle [deg]');

title(['Elevation — ', Contact.stationData(s).name]);

legend( ...
    'Elevation', ...
    'Minimum elevation', ...
    'Session start', ...
    'Session end', ...
    'Location', 'best');

end