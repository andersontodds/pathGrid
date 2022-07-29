function stroke_grid = gridstrokes(day, varargin)
% Todd Anderson
% July 27 2022
% 
% Get latitude and longitude grid of strokes detected by either all of 
% WWLLN, or single WWLLN stations.
%
% Whole network: load appropriate APfile(s), perform histcounts2 on
% stroke latitude and longitude within time bin for loop.
%
% Individual station: load appropriate pathlist(s), perform histcounts2 on
% stroke latitude and longitude within time bin for loop.

%% Input parameters:
switch class(day)
    case 'double'
        if day > 7e5 && day < 8e5
            daynum = day;
        elseif day > 19900000 && day < 21000000
            daynum = datenum(num2str(day), 'YYYYmmDD');
        else
            error('Cannot identify day format!')
        end
    case 'string'
        daynum = datenum(day, 'YYYYmmDD');
    otherwise
        error('Cannot identify day format!');
end

%starttime = daynum;
%stoptime = daynum + 1;
daystring = datestr(daynum,'YYYYmmDD');

%stations = importdata('stations.mat');

% optional parameter defaults
resolution = 10; % minutes
%wholeNetwork = 1;
%stIDRange = 1:length(stations);
stationName = "";
%singleStation = [];
%stationLatLon = [];
%custom_latlon = 0;

% check for override parameters
for i = 1 : length(varargin)

		input = varargin{i};
		
		if ischar(input) || isstring(input)
			switch varargin{i}
                case {'resolution',"resolution"}
                    resolution = varargin{i+1};
                case {'wholeNetwork',"wholeNetwork"}
					%wholeNetwork = 1;
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

                    %TODO: load APfile here?
                    APfile = importdata(filepath);
                    
                    time = datenum(APfile.data(:,1:6));
                    lat = APfile.data(:,7);
                    lon = APfile.data(:,8);
                    

                    stationName = ""; % default for whole-network save filename
%                 case {'sourceStation',"sourceStation"}
%                     %wholeNetwork = 0;
% 					sourceStation = varargin{i+1}; % value: station name to use/clone (string)
%                     station_ind = find(strcmp([stations{:,3}],sourceStation));
%                     if isempty(station_ind)
%                         error("Could not identify input station name! Check stations.mat for a list of stations.");
%                     end
%                     stIDRange = station_ind;
%                     stationLatLon = [stations{station_ind, 1:2}]; % default: same lat/lon as station to use/clone
%                     stationName = sprintf('_%s',sourceStation); % default: same string as station name to use
%                 case {'stationLatLon',"stationLatLon"}
%                     custom_latlon = 1;
% 					stationLatLon = varargin{i+1};	% value: lat/lon of simulated station (1x2 double)
%                     stationName = sprintf("_Lat%0.3fLon%0.3f", stationLatLon(1), stationLatLon(2)); % change this if you need more or less station precision in filename
                case {'stationName',"stationName"}
                    %TODO: this should be the only option needed for single stations
                    stationName = varargin{i+1};  % value: name of simulated station (string)
                    stationName = sprintf('_%s',stationName);
                    % pathlist files are only 10 minutes, so will be faster
                    % to just run getpaths(day, 'stationName', stationName)
                    %TODO: modify getpaths to allow running without saving

                    pathlist = getpaths(daynum,'stationName', stationName, 'nosave');

                    time = pathlist(:,1);   % stroke time
                    lat = pathlist(:,2);    % stroke latitude
                    lon = pathlist(:,3);    % stroke longitude

                    stationName = sprintf('_%s',stationName);

			end
		end
end

frames = 24*60/resolution; % default: 10 minute resolution --> 144 frames

%TODO: load APfile and/or run getpaths, then reduce either to arrays of
%time, lat, and lon

lat_edges = -90:90;
lon_edges = -180:180;


% 10-minute time bins
day_start = floor(time(1));
time_edge = linspace(day_start, day_start+1, 145);

stroke_grid = zeros(180, 360, length(time_edge)-1);
for i = 1:frames
    inbin = time > time_edge(i) & time < time_edge(i+1);
    stroke_grid(:,:,i) = histcounts2(lat(inbin), lon(inbin), lat_edges, lon_edges);
end

savefile = sprintf("strokegrid/strokegrid_10m_%s%s", daystring, stationName);
save(savefile, 'stroke_grid');

end