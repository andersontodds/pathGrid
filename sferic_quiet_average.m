% sferic_quiet_average.m
% Todd Anderson
% 2 May 2023
%
% Generate quiet-day average dispersion for November 2022, and save these
% to a file.

% load quiet-day dispersion
% run_start = datenum(2022, 11, 01);
% run_end = datenum(2022, 11, 30);
% run_days = run_start:run_end;
run_days = datenum(2022, 11, [6, 10, 12, 14, 15, 16, 17, 19, 21, 22, 23, 24]);
run_days = run_days';

daystr = string(datestr(run_days, "yyyymmdd"));

% cumulative average method: avoid loading entire month of grid_crossings
% at once
% NEW! cumulative average that weights things properly AND works with
% leading NaNs!

dfile = sprintf("data/sferic_grouptimediff_gridcross_10m_%s.mat", daystr(1));
d = importdata(dfile);
d_cavg = d;

d_nancount = zeros(size(d_cavg)) + isnan(d);
%% load subsequent days and calculate cumulative average
for j = 2:length(daystr)
    dfile = sprintf("data/sferic_grouptimediff_gridcross_10m_%s.mat", daystr(j));
    d = importdata(dfile);

    [d_cavg, d_nancount] = cummean3D(d, d_cavg, d_nancount, j);
    
end

% 5-degree smoothing -- note smooth2a() can handle NaNs (apparently) but
% edges and corners may not be smoothed in normal direction
for i = 1:size(d_cavg,3)
    d_quiet_sm5(:,:,i) = smooth2a(d_cavg(:,:,i), 5);
end

save("data/sferic_dispersion_10m_202211_quietavg.mat", "d_cavg");
save("data/sferic_dispersion_10m_202211_quietavg_sm5.mat", "d_quiet_sm5");

%% function definitions

function [m_cavg, m_nancount] = cummean3D(m, m_cavg, m_nancount, i)

    m_cavg_old = m_cavg;
    m_nancount = m_nancount + isnan(m);
    m_cavg(isnan(m_cavg)) = 0;
    m_big = cat(4, m_cavg.*2.*(i-1-m_nancount)./(i-m_nancount), m.*2./(i-m_nancount));
    m_cavg = mean(m_big, 4, "omitnan");
    m_cavg(isnan(m)) = m_cavg_old(isnan(m));

end