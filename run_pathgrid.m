% run_pathgrid.m
% Todd Anderson
% April 15 2022
%
% Run pathgrid analysis for days in specified range.
% Uncomment code blocks to get desired range of run_days.

% Overwrite files?  This will run new getpaths, pathgrid, and animate_pg
% even if grid_crossings_10m file exists for day(s) in range.
% OPTIONS:
%   0 : overwrite disabled
%   1 : overwrite enabled
overwrite = 0;

% specify optional arguments for getpaths.m
%   'resolution' (keyword), resolution, in minutes (default: 10)
%   'wholeNetwork' (keyword: default: enabled)
%   'singleStation' (keyword), singleStation (string)
%   'stationLatLon' (keyword), stationLatLon (1 x 2 double)
%   'stationName' (keyword), stationName (string)
sourceStation = 'Fairbanks';
stationName = sourceStation;
%stationLatLon = [68.6276, -149.5950];
%stationName = 'Toolik';

%TODO: get getpaths_args = {...} working! Currently need to edit getpaths
%arguments in function call, which is slow and prone to error
%getpaths_args = {'wholeNetwork'}; % for whole network/no simulated stations
getpaths_args = {'sourceStation', sourceStation}; % for single existing WWLLN stations
%getpaths_args = {'sourceStation', sourceStation, 'stationLatLon', stationLatLon, 'stationName', stationName}; % for simulated stations

% % X-class flare days in 2017-March 2022; from flarelist_import.m
% days = importdata('flarelist_days_20170101-20220331.mat');
% run_days = days.x_day;

% % the entire month of March 2022
% run_start = datenum(2022, 03, 01);
% run_end = datenum(2022, 03, 31);
% run_days = run_start:run_end;
% run_days = run_days';

% entire month of September 2021
run_start = datenum(2021, 09, 01);
run_end = datenum(2021, 09, 30);
run_days = run_start:run_end;
run_days = run_days';

% % the entire year of 2021
% run_start = datenum(2021, 01, 01);
% run_end = datenum(2021, 12, 31);
% run_days = run_start:run_end;
% run_days = run_days';

for i = 1:length(run_days)
    % check to see if day has been run already
    % TO DO: this switch statement is most likely redundant with the switch
    % statement at the start of getpaths; could merge the two for speed.
    switch class(run_days(i))
        case 'double'
            if run_days(i) > 7e5 && run_days(i) < 8e5
                daystring = string(datestr(run_days(i),'YYYYmmDD'));
            elseif run_days(i) > 19900000 && run_days(i) < 21000000
                daystring = string(num2str(run_days(i), '%d'));
            else
                error('Cannot identify day format!')
            end
        case 'string'
            daystring = run_days(i);
        otherwise
            error('Cannot identify day format!');
    end

    
    stationNameStr = sprintf("_%s",stationName);
    filename_gridcross = sprintf("gridstats/grid_crossings_10m_%s%s.mat",daystring,stationNameStr);
    if overwrite == 0 && isfile(filename_gridcross)
        fprintf('%s already exists and overwrite is disabled, proceeding to next day \n', filename_gridcross);
    else % either overwrite is enabled, or overwrite is disabled and grid_crossings_10m file does not yet exist for this day
        pathlist = getpaths(run_days(i),'sourceStation',sourceStation);
        pathgrid(pathlist, stationName);
        %animate_pg(run_days(i));
    end
    fprintf('Done with day %s \n',daystring);
end