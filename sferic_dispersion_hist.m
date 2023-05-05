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
all_LTlims = [0 24];

combined_LTlims = cat(1, night_LTlims, day_LTlims);

time_edge = linspace(datenum(year,month,day), datenum(year, month, day+1), size(d_quiet,3)+1);
time_face = time_edge(2:end) - (time_edge(2) - time_edge(1));
[lonmesh, latmesh] = meshgrid(-179.5:179.5, -89.5:89.5);

d_night = bininLT(d_quiet, time_face, lonmesh, night_LTlims);
d_day = bininLT(d_quiet, time_face, lonmesh, day_LTlims);
d_all = bininLT(d_quiet, time_face, lonmesh, all_LTlims);

night_med = median(d_night, "omitnan");
day_med = median(d_day, "omitnan");
all_med = median(d_all, "omitnan");

%%

h = figure(2);
delete(findall(gcf,"Tag", "anno"));
h.Position = [-1000 -200 980 600];
hold off
histogram(d_night, 0:0.005:0.2, "FaceColor", [0.6 0.2 0.6])
hold on
histogram(d_day, 0:0.005:0.2, "FaceColor", [1 0.8 0.6])
histogram(d_all, 0:0.005:0.2, "DisplayStyle", "stairs", "EdgeColor","black", "LineWidth", 1)

xline(night_med, 'Color', [0.6 0.2 0.6], "LineWidth",2);
xline(day_med, 'Color', [0.8 0.5 0.3], "LineWidth",2);
xlim([0 0.2]);

dim = [.723 .48 .3 .3];
annotation('textbox', dim, "EdgeColor", "none", 'String',{sprintf("night median: %0.1g", night_med),sprintf("day median: %0.1g", day_med)}, "FontSize", 12, "FitBoxToText","on", "Tag", "anno");

xlabel("dispersion (a_3/r)")
ylabel("counts")

l = legend("night: LT 19 to 5", "day: LT 7 to 17", "all LT");
l.FontSize = 12;

t = title("Quiet-day mean dispersion in night and day hemispheres");
t.FontSize = 20;
set(gca, "FontSize", 15)

% save
savestr = "figures/dispersion_hist_quietavg.jpg";
exportgraphics(h, savestr, "Resolution", 300)

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