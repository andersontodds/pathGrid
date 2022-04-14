function pathlist_lite = getpaths(day, resolution)
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
% NOTE: This script writes 10-minute pathlist files, so that next steps
% (e.g. pathgrid) can run with less memory use.  It outputs the full 1-day
% pathlist, though, so 
% 
% MATLAB version compatibility
%
% INPUTS:
%       day: day on which flare occurred (or for which stroke-station path
%       file is needed)
%       resolution: width of time bin, in minutes (default: 10)
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

frames = 24*60/resolution;

%% load stations, AP file

stations = importdata('stations.mat');

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


% Find every stationID; as of 11 April 2022 there are 127 entries in
% stations.dat
% 
% Note that stations.dat, stations.mat etc begin with stID == 1, i.e.
% stID == 1 corresponds to the Dunedin station

% number of columns in stroke list = APdata (10) + station ID, lat, lon (3)
pathlist = zeros(1,13);
for stID = 1:122
    [~,col] = find(stmat == stID);   %all strokes detected by station number stID
    %lidx = sub2ind(size(power),row + 1,col); %indices of strokes detected by stID in AP.power

    APdata_stID = data(col,:);
    %APpower_stID = power(lidx);
    
    % return list of stroke time, location for each station
    % need dimension stID, or vectorize and concatenate
    
    strokecount_stID = size(APdata_stID,1);
    c = ones(strokecount_stID,1);
    
    st_lat = stations{stID,1};
    st_lon = stations{stID,2};
    
    pathlist_stID = cat(2,APdata_stID,stID*c,st_lat*c,st_lon*c);
    
    pathlist = cat(1,pathlist,pathlist_stID);
    
end

%% Extract stroke-station path information: time, stroke lat/lon, station lat/lon

% time
stroke_time = datenum(pathlist(:,1:6));

% stroke lat/lon
stroke_lat = pathlist(:,7);
stroke_lon = pathlist(:,8);

% station lat/lon
stat_lat = pathlist(:,12);
stat_lon = pathlist(:,13);

pathlist_lite = cat(2,stroke_time,stroke_lat,stroke_lon,stat_lat,stat_lon);

%rand_strokes = randperm(length(pathlist),10000);

%pathlist_10000 = pathlist_lite(rand_strokes,:);


%% Save path files

minute_bin_edges = linspace(starttime,stoptime,frames+1);

for t = 1:frames
    
    pathlist_lite_10m = pathlist_lite(pathlist_lite(:,1) >= minute_bin_edges(t) & pathlist_lite(:,1) < minute_bin_edges(t+1),:);
    
    filestr = datestr(minute_bin_edges(t),'yyyymmddHHMM');
    %filenum = str2double(filestr);
    filename = sprintf('pathlist/pathlist_lite_10m_%s.mat',filestr);
    
    save(filename,'pathlist_lite_10m');
            
end

end

% save('strokelist.mat','strokelist');
% save('strokelist_lite_20170906.mat','strokelist_lite');
% save('strokelist_10000.mat','strokelist_10000');