% sferic_month_mean.m
% Todd Anderson
% 30 April 2023
%
% Generate UT average days of entire month of sferic grid crossings,
% perpendicularity, and perp-weighted grid crossings

% average each lat, lon, UT element across 1 month
% requires grid_crossings_10 files for entire time range; either download
% these from flashlight or prepend "/gridstats" to gcfile below and run
% this part on flashlight
run_start = datenum(2022, 11, 01);
run_end = datenum(2022, 11, 30);
run_days = run_start:run_end;
% run_days = datenum(2022, 11, [6, 10, 12, 14, 15, 16, 17, 19, 21, 22, 23, 24]);
run_days = run_days';
%run_days = run_days(run_days ~= datenum(2022, 01, 15));

daystr = string(datestr(run_days, "yyyymmdd"));

% cumulative average method: avoid loading entire month of grid_crossings
% at once
% NEW! cumulative average that weights things properly AND works with
% leading NaNs!

gcfile = sprintf("data/sferic_gridcrossings_10m_%s.mat", daystr(1));
gc = importdata(gcfile);
gc_cavg = gc;

perpfile = sprintf("data/sferic_perp_gridcross_10m_%s.mat", daystr(1));
perp = importdata(perpfile);
perp_cavg = perp;

% TODO: recompute quiet-day mean, and smoothed quiet-day mean, using this
% cumulative average!

gc_nancount = zeros(size(gc_cavg)) + isnan(gc);
perp_nancount = zeros(size(perp_cavg)) + isnan(perp);
%% load subsequent days and calculate cumulative average
for j = 2:length(daystr)
    gcfile = sprintf("data/sferic_gridcrossings_10m_%s.mat", daystr(j));
    gc = importdata(gcfile);

    perpfile = sprintf("data/sferic_perp_gridcross_10m_%s.mat", daystr(j));
    perp = importdata(perpfile);

    [gc_cavg, gc_nancount] = cummean3D(gc, gc_cavg, gc_nancount, j);
    [perp_cavg, perp_nancount] = cummean3D(perp, perp_cavg, perp_nancount, j);
end

gcpw_cavg = gc_cavg.*perp_cavg;

save("data/sferic_gridcross_10m_202211.mat", "gc_cavg");
save("data/sferic_perp_10m_202211.mat", "perp_cavg");
save("data/sferic_gcpw_10m_202211.mat", "gcpw_cavg");

%% cumulative mean

a = [NaN 2 3 4 5;
     1 2 NaN 4 5;
     1 2 NaN NaN 5;
     1 2 3 NaN 5];

a_cavg = a(:,1);
nancount = zeros(size(a_cavg)) + isnan(a(:,1));
for i = 2:size(a,2)

    a_cavg_old = a_cavg;
    nancount = nancount + isnan(a(:,i));
    a_cavg(isnan(a_cavg)) = 0;
    a_cavg = mean([a_cavg.*2.*(i-1-nancount)./(i-nancount) a(:,i).*2./(i-nancount)], 2, "omitnan");
    a_cavg(isnan(a(:,i))) = a_cavg_old(isnan(a(:,i)));

end

%% function definitions

function [m_cavg, m_nancount] = cummean3D(m, m_cavg, m_nancount, i)

    m_cavg_old = m_cavg;
    m_nancount = m_nancount + isnan(m);
    m_cavg(isnan(m_cavg)) = 0;
    m_big = cat(4, m_cavg.*2.*(i-1-m_nancount)./(i-m_nancount), m.*2./(i-m_nancount));
    m_cavg = mean(m_big, 4, "omitnan");
    m_cavg(isnan(m)) = m_cavg_old(isnan(m));

end
