% grid_distributions.m
% Todd Anderson
% November 29, 2022
%
% Load or generate gridcell from pathlist, filter grid by L shell, and plot
% distributions of gridcell entries for subsets of the grid.
%
% Gridcell [180 x 360 cell] contents:
%   j :             sferic path number (row index) in pathlist
%   time(j) :       stroke time
%   az_to_stroke(k):azimuth from grid location to stroke
%   c1(j) :         dispersion fit parameter: (t - r/c)
%   c2(j) :         dispersion fit parameter: phase_0
%   c3(j) :         dispersion fit parameter: w_0^2r/(2c)
%   dist(j) :       propagation distance (stroke to station)

% load pathlist
pathlist = importdata("data/pathlist_sferic_20221107.mat");

% filter time
starttime = floor(pathlist(2,1));
stoptime = starttime + 1;
frames = 24; % number of time bins per day
minute_bin_edges = linspace(starttime,stoptime,frames+1);
% generate gridcell
for m = 12
    in_frame = pathlist(:,1) > minute_bin_edges(m) & pathlist(:,1) < minute_bin_edges(m+1);
    pathlist_frame = pathlist(in_frame, :);
    gridcell = pg_gridcell_sferic(pathlist_frame);
end

% filter magnetic latitude
% note: calculating magnetic latitude is slow, but the magnetic field
% mapping shouldn't change much during the data epoch (November 2022);
% maybe save mlatmesh in a file and load this instead
% [lonmesh, latmesh] = meshgrid(-179.5:179.5,-89.5:89.5);
% mlatmesh = reshape(geog2geom(latmesh(:), lonmesh(:), 0, decyear(datevec(starttime))), 180,360);
mlatmesh = importdata("mlatmesh.mat");

%% 
auroral = (mlatmesh > 65 & mlatmesh < 75); %| (mlatmesh < -65 & mlatmesh > -75);
subauroral = (mlatmesh > 45 & mlatmesh < 65); %| (mlatmesh < -45 & mlatmesh > -65);
midlatitude = (mlatmesh > 30 & mlatmesh < 45); %| (mlatmesh < -30 & mlatmesh > -45);
% equatorial = (mlatmesh > -30 & mlatmesh < 30);

gc_auroral = gridcell(auroral);
gc_auroral = gc_auroral(~cellfun(@isempty, gc_auroral));
gc_subauroral = gridcell(subauroral);
gc_subauroral = gc_subauroral(~cellfun(@isempty, gc_subauroral));
gc_midlatitude = gridcell(midlatitude);
gc_midlatitude = gc_midlatitude(~cellfun(@isempty, gc_midlatitude));
% gc_equatorial = gridcell(equatorial);
% gc_equatorial = gc_equatorial(~cellfun(@isempty, gc_equatorial));

%% calculate and plot histograms of c3/d
gtd_auroral = [];
for i = 1:length(gc_auroral) 
    gtd = gc_auroral{i}(:,6)./gc_auroral{i}(:,7);
    gtd_auroral = [gtd_auroral; gtd];
end

gtd_subauroral = [];
for j = 1:length(gc_auroral) 
    gtd = gc_subauroral{j}(:,6)./gc_subauroral{j}(:,7);
    gtd_subauroral = [gtd_subauroral; gtd];
end

gtd_midlatitude = [];
for j = 1:length(gc_midlatitude) 
    gtd = gc_midlatitude{j}(:,6)./gc_midlatitude{j}(:,7);
    gtd_midlatitude = [gtd_midlatitude; gtd];
end

% gtd_equatorial = [];
% for j = 1:length(gc_equatorial)
%     gtd = gc_equatorial{j}(:,6)./gc_equatorial{j}(:,7);
%     gtd_equatorial = [gtd_equatorial; gtd];
% end

%%

% try histcounts
step = 0.005;
edges = 0:step:0.5;
faces = edges(1:end-1) + step/2;
ha = histcounts(gtd_auroral, edges, "Normalization","probability");
hs = histcounts(gtd_subauroral, edges, "Normalization","probability");
hm = histcounts(gtd_midlatitude, edges, "Normalization","probability");


figure(1)
hold off
plot(faces, ha);
% ha = histogram(gtd_auroral);
hold on
plot(faces, hs);
plot(faces, hm);
% hs = histogram(gtd_subauroral);
% hm = histogram(gtd_midlatitude);
% he = histogram(gtd_equatorial);
% ha.Normalization = 'probability';
% hs.Normalization = 'probability';
% hm.Normalization = 'probability';
% he.Normalization = 'probability';
% ha.BinWidth = 0.005;
% hs.BinWidth = 0.005;
% hm.BinWidth = 0.005;
% he.BinWidth = 0.005;
xlim([0 0.5]);
ylim([0 0.1]);
legend("auroral", "subauroral", "midlatitude");%, "equatorial");
xlabel("c3/d");
ylabel("fraction of total")
titlestr = sprintf("c3/d for various magnetic latitude regions, %s %s-%s", datestr(starttime, "yyyy mmmm dd"), datestr(minute_bin_edges(m), "HH:MM:SS"), datestr(minute_bin_edges(m+1), "HH:MM:SS"));
title(titlestr);

