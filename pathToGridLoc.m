% pathToGridLoc.m
% 4 October 2018
%
% This will be a function that takes as input a stroke-station pair (i.e.
% coordinates in decimal degrees) and returns lat/lon grid box locations that
% are traversed by the stroke-station path.  The function also returns the
% vector of azimuths between grid boxes on the s-s path and the stroke.
%

%% Define lat/lon grid (from de_mapper.m)
% Get longitude/latitude of each grid point
res = 1;                        %grid resolution = 1 degree
[lonGrid,latGrid] = meshgrid((-180+res/2:res:180-res/2),...
                                (-90+res/2:res:90-res/2));
                                  
lonGrid = lonGrid';
latGrid = latGrid';

% Vectorize
lonGrid = lonGrid(:);
latGrid = latGrid(:);

% % Grid borders (probably don't need to do this)
% [lonBord, latBord] = meshgrid([-180:res:179],[-90:res:90]);
% 
% lonBord = lonBord';
% latBord = latBord';
% 
% % Vectorize
% lonBord = lonBord(:);
% latBord = latBord(:);

%% Define sample great circle paths

% sample GC path with greater resolution than grid

tic

%parameters
nTracks = 10000;
timeStart = 1;
timeEnd = 100;

time = timeStart + (timeEnd-timeStart).*rand(nTracks,1);

lat1 = -90 + (89+90).*rand(nTracks,1);
lon1 = -180 + (179+180).*rand(nTracks,1);

lat2 = -90 + (89+90).*rand(nTracks,1);
lon2 = -180 + (179+180).*rand(nTracks,1);

[lattrkgc, lontrkgc] = track2(lat1,lon1,lat2,lon2,[],'degrees',400);

% place all GC path points on grid locations
lattrkgc_grid = floor(lattrkgc) + 91;
lontrkgc_grid = floor(lontrkgc) + 181;

% remove duplicate points

grid_loc = cell(nTracks,1);

for i = 1:nTracks
    
    grid_loc{i} = unique([lattrkgc_grid(:,i), lontrkgc_grid(:,i)],'rows','stable');
    
end

grid_cell = cell(180,360);
for j = 1:nTracks
   for k = 1:length(grid_loc{j})
       m = grid_loc{j}(k,:);
       grid_cell{m(1),m(2)} = [grid_cell{m(1),m(2)}; ...
           j, time(j), azimuth(m(2),m(1), lattrkgc(1,j), lontrkgc(1,j))];
   end   
end



% find number of grid crossings
grid_crossings = zeros(180,360);
for n = 1:180
   for p = 1:360
       grid_crossings(n,p) = size(grid_cell{n,p},1);
   end
    
end

toc

%% Plot GC Path crossings

%reference resolution, north max and longitude center
geoidrefvec = [1,90,0];

figure(10);
hold off;
geoshow(grid_crossings, geoidrefvec, 'DisplayType','texturemap');
hold on;
geoshow(coastlat, coastlon);

cb = colorbar('southoutside');
label = cb.Label;
label.String = 'Number of sferic crossings at grid location';
label.FontSize = 11;



%% Tiny grid: assign GCpaths to grid locations

% parameters
nTracks = 10;
timeStart = 1;
timeEnd = 100;
latSouth = 1;
latNorth = 10;
lonWest = 1;
lonEast = 10;

time = timeStart + (timeEnd-timeStart).*rand(nTracks,1);

lat3 = latSouth + (latNorth-latSouth).*rand(nTracks,1);
lon3 = lonWest + (lonEast-lonWest).*rand(nTracks,1);
lat4 = latSouth + (latNorth-latSouth).*rand(nTracks,1);
lon4 = lonWest + (lonEast-lonWest).*rand(nTracks,1);

% generate GC paths
[lattrk, lontrk] = track2(lat3,lon3,lat4,lon4,[],'degrees');

% fit GC paths into integer grid coordinates
lattrk_grid = floor(lattrk);
lontrk_grid = floor(lontrk);

% generate cell vector of grid tracks, remove duplicate points
grid_trk = cell(nTracks,1);
for i = 1:nTracks
    
    grid_trk{i} = unique([lattrk_grid(:,i), lontrk_grid(:,i)],'rows','stable');
    
end

% generate cell array w/ 1 cell per grid location, where each cell
% contains a vector of grid track traversals (track number), track time,
% and azimuth to track start
gridcell = cell(10,10);
for j = 1:10
   for k = 1:length(grid_trk{j})
       m = grid_trk{j}(k,:);
       gridcell{m(1),m(2)} = [gridcell{m(1),m(2)}; ...
           j, time(j), azimuth(m(2),m(1), lattrk(1,j), lontrk(1,j))];
   end   
end



%% Plot path, grid

load coastlines

figure(1)
hold on

% plot map
axesm('pcarree', 'MapLatLimit', [-90 90], 'MapLonLimit', [-180 180], 'ParallelLabel','on');
plotm(coastlat, coastlon);
gridm on

% plot lat/lon grid
c = colorbar();

plotm(latGrid, lonGrid, 'b.');

% plot GC tracks
plotm(grid_loc{1}, '.g');
plotm(lattrkgc(:,1),lontrkgc(:,1), 'g');
plotm(grid_loc{2}, '.r');
plotm(lattrkgc(:,2),lontrkgc(:,2), 'r');
plotm(grid_loc{3}, '.m');
plotm(lattrkgc(:,3),lontrkgc(:,3), 'm');
plotm(grid_loc{4}, '.k');
plotm(lattrkgc(:,4),lontrkgc(:,4), 'k');
plotm(grid_loc{5}, '.c');
plotm(lattrkgc(:,5),lontrkgc(:,5), 'c');

hold off


%% Sample grid intersection code
% https://www.mathworks.com/matlabcentral/answers/230155-how-to-determine-which-grid-cells-a-line-segment-passes-through
% Need to modify this code for lat/lon grid and great circle paths; need
% also angle at which gc paths cross grid locations

x = 0:25;                            % X-range
y = 0:25;                           % Y-range

lxmb = @(x,mb) mb(1).*(x - mb(2)).^2;    % Line equation: y = m*x+b

m = 1;                             % Slope (or slope array)
b = 5;                             % Intercept (or intercept array)
mb = [m b];                         % Matrix of [slope intercept] values

L1 = lxmb(x,mb);                    % Calculate Line #1 = y(x,m,b)
hix = @(y,mb) [(y-mb(2))./mb(1);  y];   % Calculate horizontal intercepts
vix = @(x,mb) [x;  lxmb(x,mb)];    % Calculate vertical intercepts

hrz = hix(x(2:end),mb)';           % [X Y] Matrix of horizontal intercepts
vrt = vix(y(1:6),mb)';             % [X Y] Matrix of vertical intercepts

hvix = [hrz; vrt];                 % Concatanated ‘hrz’ and ‘vrt’ arrays
exbd = find( (hvix(:,2) < 0) | (hvix(:,2) > 25) );
hvix(exbd,:) = [];
srtd = unique(hvix,'rows');        % Remove repeats and sort ascending by ‘x’

exL1 = find((L1 < 0) | (L1 > 25)); % Find ‘y’ values for ‘L1’ off grid
xp = x;                            % Create plotting x-vector for L1
xp(exL1) = [];                     % Eliminate out-of-bounds ‘y’ values from ‘x’
L1(exL1) = [];                     % Eliminate out-of-bounds ‘y’ values from ‘Li’

figure(3)                          % Draw grids & plot lines
plot(repmat(x,2,length(x)), [0 length(y)-1])    % Vertical gridlines
hold on
plot([0 length(x)-1], repmat(y,2,length(y)))    % Horizontal gridlines
plot(xp, L1)                        % Plot more lines here (additional ‘plot’ statements)
hold on
plot(hvix(:,1), hvix(:,2), '.b');
hold off
axis equal

