function sfericlist = getsferics(pathlist)
% getsferics.m
% Todd Anderson
% November 8 2022
%
% Gets sferic information related to lightning strokes in APfile.

% initialize output
sfericlist = zeros(length(pathlist),3);

% VLF propagation speed in the Earth-Ionosphere waveguide:
c = 299792458; % speed of light in a vacuum (m/s)
c_eiwg = 0.9905*c; % from James' email Nov 09 2022

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

% compute stroke-station distances --> time offset in pathlist
d_ss = distance(pathlist(:,2), pathlist(:,3), pathlist(:,4), pathlist(:,5), referenceEllipsoid('wgs84'));
t_ss = d_ss./c_eiwg;

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
    sfile_day = [];
    for h = 0:23
        for m = 0:59
            sfilename = sprintf("S%d%02d%02d%02d%02d",yyyy,mm,dd,h,m);
            sfile = import_sfile(sfilename);
            sfile_day = cat(1,sfile_day, sfile);
        end
    end
    % find entries in pathlist when strokes occurred that were detected by
    % station stationname(i)
    st = pathlist(:,6) == stationlist(i);
    st_stroketime = pathlist(st, 1);
    %st_strokesecs = pathlist(st, 7);
    st_stroke_dayfrac = st_stroketime - floor(st_stroketime);
    
    sferictime = sfile_day(:,1); % sferic UTC time (datenum)
    sferic_dayfrac = sferictime - floor(sferictime);
    mutoga = sfile_day(:,2); % sferic TOGA offest from UTC time (us)

    st_tss = t_ss(st);

    % match sferics to strokes

    min_dayfrac_idx = zeros(size(st_stroke_dayfrac));
    for j = 1:length(st_stroke_dayfrac)
        [~, min_dayfrac_idx(j)] = min(abs((sferic_dayfrac.*86400 + mutoga./1E6) - (st_stroke_dayfrac(j)*86400 + st_tss(j))));
    end

    % save dispersion fit parameters to sfericlist
    sfericlist(st, :) = sfile_day(min_dayfrac_idx, 5:7);

end

end