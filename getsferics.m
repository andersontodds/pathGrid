function out = getsferics(pathlist)
% getsferics.m
% Todd Anderson
% November 8 2022
%
% Gets sferic information related to lightning strokes in APfile.

% VLF propagation speed in the Earth-Ionosphere waveguide:
c = 299792458; % speed of light in a vacuum (m/s)
c_eiwg = 0.9914*c; % band-averaged group velocity == propagation speed in EIWG (Dowden et al 2002)

% Get date(s) of pathlist
% usually each pathlist will be run for a single day
date = unique(floor(pathlist(:,1))); % in datenum format
yyyy = year(datetime(date(1), "ConvertFrom", "datenum")); % if multi-day pathlists are needed, change this from date(1) to date
mm   = month(datetime(date(1), "ConvertFrom", "datenum"));% if multi-day pathlists are needed, change this from date(1) to date
dd   = day(datetime(date(1), "ConvertFrom", "datenum"));  % if multi-day pathlists are needed, change this from date(1) to date

% Check pathlist for unique stations
% station IDs here will start at 1, not 0
stations = importdata("stations.mat");
stationlist = unique(pathlist(:,6)); 
% convert station ID to lowercase station name
stationname = lower([stations{stationlist, 3}]);

% Get Sfiles for each station in pathlist
% for i in each station, j in each date
% cp /flashproc/wd4/cchris28/S-files/stationname(i)/yyyy/Syyyymmdd*.tar.bz2 ./S-files/stationname(i)/yyyy/
% bunzip2 Syyyymmdd*.tar.bz2    --> SyyymmddHH.tar
% tar -xf Syyyymmdd*.tar        --> SyyyymmddHHMM
for i = 1:length(stationname)
    flashprocpath = sprintf("/flashproc/wd4/cchris28/S-files/%s/%d", stationname(i), yyyy);
    flashlightpath = sprintf("./S-files/%s/%d", stationname(i), yyyy);
    cmd_cp = sprintf("cp %s/S%d%02d%02d*.tar.bz2 %s", flashprocpath, yyyy,mm,dd, flashlightpath);
    [status] = system(cmd_cp);
    cmd_bunzip2 = sprintf("bunzip2 %s/S%d%02d%02d.tar.bz2", flashlightpath, yyyy,mm,dd);
    [status] = system(cmd_bunzip2);
    tarname = sprintf("%s/S%d%02d%02d*.tar", flashlightpath, yyyy,mm,dd);
    untar(tarname);

    % at this point, all Sfiles for stationname(i) on the same date as
    % pathlist should be unzipped and untarred.  Next, extract pertinent
    % sferic information from all of them, and save them to a list.
    % This should be its own function; modify read_sfile.m

    % for each Sfile,
    %   get or calculate pertinent sferic information --> readSfile
    % save daily information
    
    % find entries in pathlist when strokes occurred that were detected by
    % station stationname(i)
    st = pathlist(:,6) == stationlist(i);
    station_stroketimes = pathlist(st, 1);
    ss_distance = distance(pathlist(st, 2),pathlist(st, 3), pathlist(st, 4), pathlist(st, 5), 6371);
    sferic_time = ss_distance./c_eiwg;

end

end