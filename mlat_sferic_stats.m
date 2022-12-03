% mlat_sferic_stats.m
% Todd Anderson
% 3 December 2022
%
% Find gridcell locations in magnetic latitude bins, and plot statistics of
% these.  Try other filters like day/night, land/sea,
% perpendicularity-weighted number of paths threshold

year = 2022;
month = 11;
day = 22;

gtdfile = sprintf("data/sferic_grouptimediff_gridcross_10m_%04g%02g%02g.mat", year, month, day);
perpfile = sprintf("data/sferic_perp_gridcross_10m_%04g%02g%02g.mat", year, month, day);
gcfile = sprintf("data/sferic_gridcrossings_10m_%04g%02g%02g.mat", year, month, day);
gtd = importdata(gtdfile);
perp = importdata(perpfile);
gc = importdata(gcfile);

gcpw = gc.*perp;
gcpw_threshold = 1;

mlatmesh = importdata("mlatmesh.mat");
lsi = importdata("../landseaice/LSI_maskonly.mat");

time_edge = linspace(datenum(year,month,day), datenum(year, month, day+1), size(gtd,3)+1);
time_face = time_edge(2:end) - (time_edge(2) - time_edge(1));

mlatrange = 50:70;

colors = crameri('-lajolla', length(mlatrange)+2);
colors = colors(2:end-1, :);

figure(4)
hold off

gtd_mean = zeros(size(gtd, 3), length(mlatrange));
for i = 1:length(mlatrange)
    grid_in_bin = round(mlatmesh) == mlatrange(i);
    for j = 1:size(gtd, 3)
        gtd_frame = gtd(:,:,j);
        gcpw_above_threshold = gcpw(:,:,j) > gcpw_threshold;
        % mean gtd over mlat bin, accounting for different number of paths
        % crossing each grid location
        totalgc = sum(gc(grid_in_bin & gcpw_above_threshold));
        gtd_mean(j,i) = sum(gtd_frame(grid_in_bin & gcpw_above_threshold).*gc(grid_in_bin & gcpw_above_threshold)/totalgc, "omitnan");
        % mean of grid locations in mlat bin, not accounting for number of paths crossing each location    
%         gtd_mean(j,i) = mean(gtd_frame(grid_in_bin & gcpw_above_threshold), "omitnan"); 
    end

    plot(datetime(time_face, "ConvertFrom","datenum"), gtd_mean(:,i), '-', "Color", colors(i,:))
    hold on
end

ylabel("c3/d")
ylim([0.025 0.125])
