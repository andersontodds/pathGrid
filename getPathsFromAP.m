% getPathsFromAP.m
% 12 December 2018
% 
% Prepares files for use with pathGrid.m.  Imports APfile(s) and
% stations.mat, combines APfiles if necessary, finds station lat/lon
% coordinates in stations.dat, and creates files containing all
% stroke-station path files from APfile(s).  Note that all strokes
% contained in APfile will be associated with at least 5 stations, the
% lower bound on the length of the output file is 5*length(AP.data or
% AP.power).
%
% NOTE: This script outputs 10-minute strokelist files, so that next steps
% (e.g. pathGrid) can run with less memory use.
% 
% INPUTS:
%       APfile(s)
%       stations.mat
%
% OUTPUTS:
%       stroke-station path file
% 

%% Input parameters:

% Enter start and stop APfile dates (inclusive).  For a single-day APfile,
% startnum = stopnum.
startnum = 20170907;
stopnum = 20170907;

starttime = datenum(2017,09,07,00,00,00);
stoptime = datenum(2017,09,08,00,00,00);

frames = 144;

%% load AE, AP files

load('stations.mat');

flrAE       = [];
flrAPdata   = [];
flrAPpower  = [];
% date range
for k = startnum:stopnum
    AEfilename = sprintf('AE%d.mat',k);
    AEfile = importdata(AEfilename);
    
    % append current AE file to previous loop iteration's AE file
    flrAE = cat(1,flrAE,AEfile);
    
    APfilename = sprintf('AP%d.mat',k);
    APfile = importdata(APfilename);
    data = APfile.data;
    power = APfile.power;
    
    % append current AP.data, AP.power to previous loop iteration's AP data
    % and power
    flrAPdata = cat(1,flrAPdata,data);
    flrAPpower = cat(2,flrAPpower,power);
    
end

%% (optional) UTC filter

% utc_index = find(flrAE(:,4) >= 16 & flrAE(:,4) < 18);
% 
% flrAE = flrAE(utc_index,:);
% flrAPdata = flrAPdata(utc_index,:);
% flrAPpower = flrAPpower(:,utc_index);


%% setup: load regional AE, AP files

bigAE = flrAE;
bigAPdata = flrAPdata;
bigAPpower = flrAPpower;

%% station sets: find stationIDs in AP.power a la detectDist.m

strows = bigAPpower(1:2:end,:);
% convert stID from 0-start to 1-start, except station 0 (Dunedin)
strows(strows > 0) = strows(strows > 0) + 1;
nullrows = NaN.*ones(size(strows));
stmat = ones(size(bigAPpower));
stmat(1:2:end,:) = strows;
stmat(2:2:end,:) = nullrows;

% find stID == 0 on first line only and convert to stID == 1
stmatr1 = stmat(1,:);
stmatr1(stmatr1 == 0) = 1;
stmat(1,:) = stmatr1;


% Find every stationID; as of 4 Oct 2018 there are 122 entries in
% stations.dat
% 
% Note that stations.dat, stations.mat etc begin with stID == 1, i.e.
% stID == 1 corresponds to the Dunedin station

% number of columns in stroke list = APdata (10) + station ID, lat, lon (3)
strokelist = zeros(1,13);
for stID = 1:122
    [row,col] = find(stmat == stID);   %all strokes detected by station number stID
    lidx = sub2ind(size(bigAPpower),row + 1,col); %indices of strokes detected by stID in bigAPpower

    AE_stID = bigAE(col,:);
    APdata_stID = bigAPdata(col,:);
    APpower_stID = bigAPpower(lidx);
    
    % return list of stroke time, location for each station
    % need dimension stID, or vectorize and concatenate
    
    strokecount_stID = size(APdata_stID,1);
    c = ones(strokecount_stID,1);
    
    st_lat = stations{stID,1};
    st_lon = stations{stID,2};
    
    strokelist_stID = cat(2,APdata_stID,stID*c,st_lat*c,st_lon*c);
    
    strokelist = cat(1,strokelist,strokelist_stID);
    
end

%% Extract stroke-station path information: time, stroke lat/lon, station lat/lon

% time
stroke_time = datenum(strokelist(:,1:6));

% stroke lat/lon
stroke_lat = strokelist(:,7);
stroke_lon = strokelist(:,8);

% station lat/lon
stat_lat = strokelist(:,12);
stat_lon = strokelist(:,13);

strokelist_lite = cat(2,stroke_time,stroke_lat,stroke_lon,stat_lat,stat_lon);

rand_strokes = randperm(length(strokelist),10000);

strokelist_10000 = strokelist_lite(rand_strokes,:);


%% Save path files

minute_bin_edges = linspace(starttime,stoptime,frames+1);

for t = 1:frames
    
    strokelist_lite_10m = strokelist_lite(strokelist_lite(:,1) >= minute_bin_edges(t) & strokelist_lite(:,1) < minute_bin_edges(t+1),:);
    
    filestr = datestr(minute_bin_edges(t),'yyyymmddHHMM');
    filenum = str2double(filestr);
    filename = sprintf('strokelist_lite_10m_%d.mat',filenum);
    
    save(filename,'strokelist_lite_10m');
            
end

% save('strokelist.mat','strokelist');
% save('strokelist_lite_20170906.mat','strokelist_lite');
% save('strokelist_10000.mat','strokelist_10000');
