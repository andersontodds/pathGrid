% sferic_dispersion_hist.m
% Todd Anderson
% 3 May 2023
%
% Generate histograms of sferic dispersion based on local time, or other
% parameters.

d_quiet = importdata("data/sferic_dispersion_10m_202211_quietavg.mat");

year = 2022;
month = 11;
day = 15;

night_LTlims = [19 5];
day_LTlims = [7 17];

combined_LTlims = cat(1, night_LTlims, day_LTlims);

time_edge = linspace(datenum(year,month,day), datenum(year, month, day+1), size(d_quiet,3)+1);
time_face = time_edge(2:end) - (time_edge(2) - time_edge(1));
[lonmesh, latmesh] = meshgrid(-179.5:179.5, -89.5:89.5);

d_night = bininLT(d_quiet, time_face, lonmesh, night_LTlims);
d_day = bininLT(d_quiet, time_face, lonmesh, day_LTlims);

figure(2)
hold off
histogram(d_night, 0:0.005:0.2)
hold on
histogram(d_day, 0:0.005:0.2)

% TODO: make pretty, calculate median + std range
% d_night_med = median(d_night, "all","omitnan");
% d_day_med = median(d_day, "all","omitnan");
% d_night_std = std(d_night, "all","omitnan");
% d_day_std = std(d_day, "all","omitnan");



%% define functions

function d_out = bininLT(d_in, time_face, lonmesh, LTlims)

d_out = NaN;
for i = 1:length(time_face)
    d_frame = d_in(:,:,i);
    LTmesh = localsolartime(time_face(i), lonmesh, 0);
    LTmesh = mod(LTmesh, 24);
    
    % generate day and night histograms
%     LTlims = night_LTlims;
    if LTlims(1) < LTlims(2)
        grid_in_LT = LTmesh > LTlims(1) & LTmesh < LTlims(2);
    elseif LTlims(1) > LTlims(2)
        grid_in_LT = LTmesh > LTlims(1) | LTmesh < LTlims(2);
    else
        error("check LTlims!");
    end

    d_inLT = d_frame(grid_in_LT);
    d_inLT = d_inLT(:);
    d_out = cat(1, d_out, d_inLT);

end

end