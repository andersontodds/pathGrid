function pathlist_sferic = getsferics(pathlist)
% getsferics.m
% Todd Anderson
% November 8 2022
%
% Gets sferic information related to lightning strokes in APfile.

% initialize sfericlist
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
    flashprocfile = sprintf("%s/S%d%02d%02d*.tar.bz2", flashprocpath, yyyy,mm,dd);
    flashlightpath = sprintf("./S-files/%s/%d", stationname(i), yyyy);
    % check that source and destination folders exist, and that source
    % folder is not empty
    % conditions:
    %   source directory exists     | source directory is non-empty  | destination directory exists | source directory has at least one file in date range
    if exist(flashprocpath, "dir") && numel(dir(flashprocpath)) > 2 && exist(flashlightpath,"dir") && numel(dir(flashprocfile)) > 0
        msg = sprintf("Copying Sfiles from %s", flashprocpath);
        disp(msg);
        cmd_cp = sprintf("cp %s %s", flashprocfile, flashlightpath);
        [status] = system(cmd_cp);
    else
        msg = sprintf("No Sfiles from %s, going to next station.", stationname(i));
        disp(msg);
        continue;
    end


    % for each Sfile,
    %   get or calculate pertinent sferic information --> readSfile
    % save daily information
    sfile_day = [];
    for HH = 0:23
        path_bunzip2 = sprintf("%s/S%d%02d%02d%02d.tar.bz2", flashlightpath, yyyy,mm,dd,HH);
        if ~exist(path_bunzip2, "file")
            continue;
        end
        cmd_bunzip2 = sprintf("bunzip2 %s", path_bunzip2);
        [status] = system(cmd_bunzip2);
        tarname = sprintf("%s/S%d%02d%02d%02d.tar", flashlightpath, yyyy,mm,dd,HH);
        untar(tarname, flashlightpath);

        for MM = 0:59
            sfilename = sprintf("%s/S%d%02d%02d%02d%02d",flashlightpath,yyyy,mm,dd,HH,MM);
            if ~exist(sfilename, "file")
                continue;
            end
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

    min_dayfrac = zeros(size(st_stroke_dayfrac));
    min_dayfrac_idx = zeros(size(st_stroke_dayfrac));
    for j = 1:length(st_stroke_dayfrac)
        [min_dayfrac(j), min_dayfrac_idx(j)] = min(abs((sferic_dayfrac.*86400 + mutoga./1E6) - (st_stroke_dayfrac(j)*86400 + st_tss(j)))); % units: seconds
    end

    % save dispersion fit parameters to sfericlist
    bad_fit = min_dayfrac > 1E-4; % i.e. could not find sferic within 100 us
    sfericlist(st, :) = sfile_day(min_dayfrac_idx, 5:7);
    if any(bad_fit)
        sfericlist(st(bad_fit), :) = [NaN NaN NaN];
    end

    % clean up untarred Sfiles

    if numel(dir(sprintf("%s/S!(*.*)", flashlightpath))) > 0
        cmd_rm = sprintf("rm %s/S!(*.*)", flashlightpath);
        [status] = system(cmd_rm);
    end

end

% get subset of pathlist with nonzero sferic information
c1zero = sfericlist(:,1) == 0;
c2zero = sfericlist(:,2) == 0;
c3zero = sfericlist(:,3) == 0;
goodsferics = ~(c1zero & c2zero & c3zero);

sferics = sfericlist(goodsferics, :);
sfericpaths = pathlist(goodsferics, :);

pathlist_sferic = cat(2, sfericpaths, sferics);

savename = sprintf("./pathlist/pathlist_sferic_%04d%02d%02d.mat", yyyy,mm,dd);
save(savename, "pathlist_sferic");

end