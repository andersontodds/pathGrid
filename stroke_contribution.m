% stroke_contribution.m
% Todd Anderson
% July 27, 2022
%
% Find and plot proportion of WWLLN strokes that a selected individual
% station contributes to locating.

%% get whole network distribution from APfile, divide into 180x360x144 grid
% grid dimensions:
%   latitude: (-90, 90] with 1-degree resolution = 180 elements
%   longitude: (-180, 180] with 1-degree resolution = 360 elements
%   time:       0:10minutes:24hours = 144 elements

daynum = datenum(2022,03,01);

daystring = datestr(daynum,'YYYYmmDD');
year = datestr(daynum, 'YYYY');

APfilename = sprintf('AP%s.mat',daystring);

switch year
    case {'2017','2018','2019'}
        filepath = compose("/flash5/wd2/APfiles/%s/%s",year,APfilename);
    case {'2020','2021','2022'}
        filepath = compose("/flash5/wd2/APfiles/%s",APfilename);
    otherwise
        error('Input year outside range 2017-2022!')
end

fprintf('attempting import from path %s \n', filepath)
APfile = importdata(filepath);
data = APfile.data;
power = APfile.power;

time = datenum(data(:,1:6));
lat = data(:,7);
lon = data(:,8);

lat_edges = -90:90;
lon_edges = -180:180;

% % whole day
% [stroke_grid_day, lat_edges, lon_edges] = histcounts2(lat, lon, lat_edges, lon_edges);

% 10-minute time bins
day_start = floor(time(1));
time_edge = linspace(day_start, day_start+1, 145);

stroke_grid = zeros(180, 360, length(time_edge)-1);
for i = 1:length(time_edge)-1
    inbin = time > time_edge(i) & time < time_edge(i+1);
    stroke_grid(:,:,i) = histcounts2(lat(inbin), lon(inbin), lat_edges, lon_edges);
end


savefile = sprintf("strokegrid/strokegrid_10m_%s", daystring);
save(savefile, 'stroke_grid');

%%  plot

load coastlines;
geoidrefvec = [1,90,-180];

for j = 1:size(stroke_grid, 3)
    
    figure(2)
    hold off
    worldmap("World");
    geoshow(stroke_grid(:,:,j), geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color", "white");
    
    set(gca, 'ColorScale', 'log');
    crameri('tokyo')
    colorbar('eastoutside');

    drawnow;

end