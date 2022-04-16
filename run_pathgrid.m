% run_pathgrid.m
% Todd Anderson
% April 15 2022
%
% Run pathgrid analysis for days in 20170101-20220330 chosen from
% flarelist_import.m
%
% April 15: Try days with X-class flares first (9 total).

days = importdata('flarelist_days_20170101-20220331.mat');

x_day = days.x_day;

for i = 1:length(x_day)
    pathlist = getpaths(x_day(i), 10);
    pathgrid(pathlist);
    animate_pg(x_day(i));

    fprintf('Done with day %s',num2str(x_day(i)));
end