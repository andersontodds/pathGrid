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

% % X-class flare days in 2017-March 2022; from flarelist_import.m
% days = importdata('flarelist_days_20170101-20220331.mat');
% run_days = days.x_day;

% the entire month of March 2022
run_start = datenum(2022, 03, 01);
run_end = datenum(2022, 03, 31);
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

    filename_gridcross = sprintf("gridstats/grid_crossings_10m_%s.mat",daystring);
    if overwrite == 0 && isfile(filename_gridcross)
        fprintf('%s already exists and overwrite is disabled, proceeding to next day \n', filename_gridcross);
    else % either overwrite is enabled, or overwrite is disabled and grid_crossings_10m file does not yet exist for this day
        pathlist = getpaths(run_days(i), 10);
        pathgrid(pathlist);
        %animate_pg(run_days(i));
    end
    fprintf('Done with day %s \n',daystring);
end