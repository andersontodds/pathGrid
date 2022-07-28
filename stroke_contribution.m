% stroke_contribution.m
% Todd Anderson
% July 27, 2022
%
% Plot maps of WWLLN strokes detected by the whole network and subsets of
% the network (e.g. single stations).

% TODO: average month of strokegrid in UT

%% import data

run_start = datenum(2022, 03, 01);
run_end = datenum(2022, 03, 31);
run_days = run_start:run_end;
run_days = run_days';

daystr = string(datestr(run_days, "yyyymmdd"));

filestr = sprintf("data/strokegrid_10m_%s.mat", daystr);
sg = importdata(filestr);

%%  plot whole day
sg_day = sum(sg, 3);

load coastlines;
geoidrefvec = [1,90,-180];


figure(1)
hold off
worldmap("World");
geoshow(sg_day, geoidrefvec, "DisplayType","texturemap");
hold on
geoshow(coastlat, coastlon, "Color", "white");

set(gca, 'ColorScale', 'log');
crameri('tokyo')
colorbar('eastoutside');

title()


%% animate 10-minute windows
for j = 1:size(stroke_grid, 3)
    
    figure(2)
    hold off
    worldmap("World");
    geoshow(sg(:,:,j), geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color", "white");
    
    set(gca, 'ColorScale', 'log');
    crameri('tokyo')
    colorbar('eastoutside');

    drawnow;

end