% run_gridstrokes.m
% Todd Anderson
% July 28 2022
%
% Run gridstrokes function for series of days.  Plot results with
% stroke_contribution.m

% Overwrite files?  This will run new gridstrokes
% even if strokegrid_10m file exists for day(s) in range.
% OPTIONS:
%   0 : overwrite disabled
%   1 : overwrite enabled
overwrite = 0;

% specify optional arguments for getpaths.m
%   'resolution' (keyword), resolution, in minutes (default: 10)
%   'wholeNetwork' (keyword: default: enabled)
%   'stationName' (keyword), stationName (string)
stationNameList = ["Fairbanks"; "Churchill"; "Sodankyla"];

% run_days:
% the entire month of March 2022
run_start_mar = datenum(2022, 03, 01);
run_end_mar = datenum(2022, 03, 31);
run_days_mar = run_start_mar:run_end_mar;
run_days_mar = run_days_mar';

run_days = [run_days_mar]; % cat multiple run_days blocks if necessary

for j = 1:length(stationNameList)
    stationName = stationNameList(j);

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
        filename_strokegrid = sprintf("strokegrid/strokegrid_10m_%s%s.mat",daystring);%,stationNameStr);
        if overwrite == 0 && isfile(filename_strokegrid)
            fprintf('%s already exists and overwrite is disabled, proceeding to next day \n', filename_strokegrid);
        else % either overwrite is enabled, or overwrite is disabled and grid_crossings_10m file does not yet exist for this day
            strokegrid = gridstrokes(run_days(i),'stationName', stationName);
        end
        fprintf('Done with day %s \n',daystring);
    end

end