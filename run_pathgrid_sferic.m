% run_pathgrid_sferic.m
% Todd Anderson
% November 14 2022
%
% Run pathgrid_sferic analysis for days in specified range.
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
% sourceStationList = ["Fairbanks"];%; "Churchill"; "Sodankyla"];
% sourceStationList = ["Fairbanks"; "Fairbanks"; ...
%                     "Churchill"; "Churchill";
%                     "Sodankyla"];
% stationNameList = sourceStationList;
% stationLatLonList = [64.8737, -147.8605]; % Fairbanks
% stationLatLonList = [68.6276, -149.5950; 71.2933, -156.7641; ...
%                     63.7659, -68.5634; 72.6911, -77.9560; ...
%                     78.2321, 15.5145];
% stationNameList = ["Toolik"; "Utqiagvik"; ...
%                   "Iqaluit"; "PondInlet"; ...
%                   "Longyearbyen"];

%TODO: get getpaths_args = {...} working! Currently need to edit getpaths
%arguments in function call, which is slow and prone to error
%getpaths_args = {'wholeNetwork'}; % for whole network/no simulated stations
%getpaths_args = {'sourceStation', sourceStation}; % for single existing WWLLN stations
%getpaths_args = {'sourceStation', sourceStation, 'stationLatLon', stationLatLon, 'stationName', stationName}; % for simulated stations

% % X-class flare days in 2017-March 2022; from flarelist_import.m
% days = importdata('flarelist_days_20170101-20220331.mat');
% run_days = days.x_day;

% % the entire month of January 2022; includes Hunga Tonga Ha'apai explosive
% % eruption on Jan 15 04 UT
% run_start_jan = datenum(2022, 01, 01);
% run_end_jan = datenum(2022, 01, 31);
% run_days_jan = run_start_jan:run_end_jan;
% run_days_jan = run_days_jan';
% 
% % the entire month of March 2022
% run_start_mar = datenum(2022, 03, 01);
% run_end_mar = datenum(2022, 03, 31);
% run_days_mar = run_start_mar:run_end_mar;
% run_days_mar = run_days_mar';
% 
% % entire month of September 2021
% run_start_sep = datenum(2021, 09, 01);
% run_end_sep = datenum(2021, 09, 30);
% run_days_sep = run_start_sep:run_end_sep;
% run_days_sep = run_days_sep';

% the month of November 2022 so far
run_start_nov = datenum(2022, 11, 17); % already ran Nov 1-16
run_end_nov = datenum(2022, 11, 25);
run_days_nov = run_start_nov:run_end_nov;
run_days_nov = run_days_nov';


run_days = [run_days_nov];

% % the entire year of 2021
% run_start = datenum(2021, 01, 01);
% run_end = datenum(2021, 12, 31);
% run_days = run_start:run_end;
% run_days = run_days';

% for j = 1:length(sourceStationList)
    %sourceStation = sourceStationList(j);
    %stationLatLon = stationLatLonList(j,:);
    %stationName = stationNameList(j);

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
    
        
        %stationNameStr = sprintf("_%s",stationName);
        filename_gtd = sprintf("gridstats/sferic_grouptimediff_gridcross_10m_%s.mat",daystring);%,stationNameStr); % add second "%s" if using individual station option 
        filename_pls = sprintf("pathlist/pathlist_sferic_%s.mat", daystring);
        if overwrite == 0 && isfile(filename_gtd)
            fprintf('%s already exists and overwrite is disabled, proceeding to next day \n', filename_gtd);
        elseif overwrite == 0 && isfile(filename_pls) % pathlist_sferic already exists, but grouptimediff file does not
            fprintf('%s already exists and overwrite is disabled, running pathgrid with this pathlist file. \n', filename_pls);
            pathlist_sferic = importdata(filename_pls);
            pathgrid_sferic(pathlist_sferic);
        else % either overwrite is enabled, or overwrite is disabled and grid_crossings_10m file does not yet exist for this day
            pathlist = getpaths(run_days(i));%,'sourceStation',sourceStation, 'stationLatLon', stationLatLon, 'stationName', stationName);
            pathlist_sferic = getsferics(pathlist);
            pathgrid_sferic(pathlist_sferic);%, stationName);
            %animate_pg(run_days(i));
        end
        fprintf('Done with day %s \n',daystring);
    end

% end