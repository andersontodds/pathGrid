function pathlist_lite = getpaths(day, varargin)
% getpaths.m
% Todd Anderson
% April 11, 2022
%
% Function version getPathsFromAP.m.
%
% Prepares files for use with pathGrid.m.  Imports APfile and
% stations.mat, finds station lat/lon
% coordinates in stations.mat, and creates files containing all
% stroke-station path files from APfile.  Note that all strokes
% contained in APfile will be associated with at least 5 stations, the
% lower bound on the length of the output file is 5*length(AP.data or
% AP.power).
%
% NOTE: This script writes 10-minute pathlist files, but outputs the
% whole-day pathlist.  The next step, pathgrid.m, can immediately use the
% whole-day pathlist for calculating grid_cell and grid_crossings, other
% uses of pathlist files outside of the normal pathgrid workflow can
% benefit from smaller files.
% 
% MATLAB version compatibility: R2019a+, I think?
%
% INPUTS:
%       day: day on which flare occurred (or for which stroke-station path
%       file is needed)
%
%   Optional inputs:
%       resolution: width of time bin, in minutes (default: 10)
%
%   Keywords/keyword-value pairs:
%       'wholeNetwork': use all stations in stations.mat (default)
%
%       'singleStation': use only the station specified in the next
%       argument.  Make sure spelling and capitalization match station
%       names in stations.mat! %TODO optionally specify station ID instead
%       of name
%
%       'stationLatLon': if singleStation and stationLatLon are specified,
%       next argument specifies the latitude and longitude to use for 
%       station location.  The default is the latitude and longitude for 
%       the specified singleStation in stations.mat.  Alternatively, 
%       stationLatLon can be specified as any [lat lon] pair, which has the
%       effect of making a pathlist with stroke locations equal to those 
%       located by singleStation, with a simulated station location.
%
%       'stationName': next argument specifies name of simulated station.  If
%       stationName is not used, default is either name of actual WWLLN
%       station (from singleStation) if stationLatLon is not used, or
%       string synthesized from stationLatLon if applicable.
%
%       
%
% Requires:
%       APfile for input day at /flash5/wd2/APfiles/[YEAR/]
%       stations.mat
%
% OUTPUTS:
%       stroke-station path file
% 

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

starttime = daynum;
stoptime = daynum + 1;

stations = importdata('stations.mat');

% optional parameter defaults
saveOption = 1;
resolution = 10; % minutes
%wholeNetwork = 1;
stIDRange = 1:length(stations);
stationName = "";
%singleStation = [];
%stationLatLon = [];
custom_latlon = 0;

% check for override parameters
for i = 1 : length(varargin)

		input = varargin{i};
		
		if ischar(input) || isstring(input)
			switch varargin{i}
                case {'nosave'}
                    saveOption = 0;
                case {'resolution',"resolution"}
                    resolution = varargin{i+1};
                case {'wholeNetwork',"wholeNetwork"}
					%wholeNetwork = 1;
                    stIDRange = 1:length(stations);
                    stationName = ""; % default for whole-network save filename
                case {'sourceStation',"sourceStation"}
                    %wholeNetwork = 0;
					sourceStation = varargin{i+1}; % value: station name to use/clone (string)
                    station_ind = find(strcmp([stations{:,3}],sourceStation));
                    if isempty(station_ind)
                        error("Could not identify input station name! Check stations.mat for a list of stations.");
                    end
                    stIDRange = station_ind;
                    stationLatLon = [stations{station_ind, 1:2}]; % default: same lat/lon as station to use/clone
                    stationName = sprintf('_%s',sourceStation); % default: same string as station name to use
                case {'stationLatLon',"stationLatLon"}
                    custom_latlon = 1;
					stationLatLon = varargin{i+1};	% value: lat/lon of simulated station (1x2 double)
                    stationName = sprintf("_Lat%0.3fLon%0.3f", stationLatLon(1), stationLatLon(2)); % change this if you need more or less station precision in filename
                case {'stationName',"stationName"}
                    stationName = varargin{i+1};  % value: name of simulated station (string)
                    stationName = sprintf('_%s',stationName);
			end
		end
end

frames = 24*60/resolution; % default: 10 minute resolution --> 144 frames

%% load AP file

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

%% (optional) UTC filter

% utc_index = find(flrAE(:,4) >= 16 & flrAE(:,4) < 18);
% 
% flrAE = flrAE(utc_index,:);
% flrAPdata = flrAPdata(utc_index,:);
% flrAPpower = flrAPpower(:,utc_index);

%% station sets: find stationIDs in AP.power a la detectDist.m

strows = power(1:2:end,:);
% convert stID from 0-start to 1-start, except station 0 (Dunedin)
strows(strows > 0) = strows(strows > 0) + 1;
nullrows = NaN.*ones(size(strows));
stmat = ones(size(power));
stmat(1:2:end,:) = strows;
stmat(2:2:end,:) = nullrows;

% find stID == 0 on first line only and convert to stID == 1
stmatr1 = stmat(1,:);
stmatr1(stmatr1 == 0) = 1;
stmat(1,:) = stmatr1;


% Find every stationID; as of July 2022 there are 128 entries in
% stations.dat
% 
% Note that stations.dat, stations.mat etc begin with stID == 1, i.e.
% stID == 1 corresponds to the Dunedin station

% number of columns in stroke list = APdata (10) + station ID, lat, lon (3)
pathlist = zeros(1,13);
for stID = stIDRange
    [~,col] = find(stmat == stID);   %all strokes detected by station number stID
    %lidx = sub2ind(size(power),row + 1,col); %indices of strokes detected by stID in AP.power

    APdata_stID = data(col,:);
    %APpower_stID = power(lidx);
    
    % return list of stroke time, location for each station
    % need dimension stID, or vectorize and concatenate
    
    strokecount_stID = size(APdata_stID,1);
    c = ones(strokecount_stID,1);
    
    if custom_latlon == 1
        st_lat = stationLatLon(1);
        st_lon = stationLatLon(2);
    else
        st_lat = stations{stID,1};
        st_lon = stations{stID,2};
    end
    
    pathlist_stID = cat(2,APdata_stID,stID*c,st_lat*c,st_lon*c);
    
    pathlist = cat(1,pathlist,pathlist_stID);
    
end

pathlist(1,:) = []; % remove first row of zeros

%% Extract stroke-station path information: time, stroke lat/lon, station lat/lon

% time
stroke_time = datenum(pathlist(:,1:6));

% stroke lat/lon
stroke_lat = pathlist(:,7);
stroke_lon = pathlist(:,8);

% station lat/lon, ID
stat_lat = pathlist(:,12);
stat_lon = pathlist(:,13);
stat_ID  = pathlist(:,11);

pathlist_lite = cat(2,stroke_time,stroke_lat,stroke_lon,stat_lat,stat_lon,stat_ID);

%% Save path files

if saveOption == 1
    minute_bin_edges = linspace(starttime,stoptime,frames+1);
    
    for t = 1:frames
        
        pathlist_lite_10m = pathlist_lite(pathlist_lite(:,1) >= minute_bin_edges(t) & pathlist_lite(:,1) < minute_bin_edges(t+1),:);
        
        filestr = datestr(minute_bin_edges(t),'yyyymmddHHMM');
        %filenum = str2double(filestr);
        filename = sprintf('pathlist/pathlist_lite_10m_%s%s.mat',filestr,stationName);
        
        save(filename,'pathlist_lite_10m');
                
    end

end

end
