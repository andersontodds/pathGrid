function pathgrid(pathlist)
% pathgrid.m
% Todd Anderson
% April 13, 2022
%
%
% Function version of pathGrid_10m.m, pathGrid_fullstats_10m, etc.
%
% Takes 10-minute stroke-station pair files as input and calculates
% whole-day matrix of stroke-station path crossings, including number,
% difference from trailing mean, and azimuthal statistics, as well as
% calculating subsolar attenuation contours. Clears grid_cell before
% loading next 10-minute file to reduce memory usage.
%
% MATLAB version compatibility: R2016a and newer (movmean.m introduced)
%
% INPUTS:
%       
%       pathlist: matrix of stroke-station pairs generated by getpaths.m
%           from APfiles. Whole-day version.
%
%       day: if using 10-minute pathlist files, specify which day of
%           pathlist files to use.
%       pathlist_lite_10m_*.mat
%           File of stroke-station pairs generated by getpaths.m from
%           APfiles.  10-minute version has name format
%           pathlist_lite_10m_yyyymmddHHMM.mat.
%
% FUNCTIONS:
%       pg_gridcell.m
%           Converts strokelist to 180 x 360 cell array 'grid_cell'.  These
%           outputs are large (total 1-day = several GB), so each grid_cell
%           is cleared before proceding to next 10-minute strokelist.
%
%       pg_gridcross.m
%           Converts grid_cell to grid_crossings, a 180 x 360 matrix.  Each
%           element is the length of the corresponding cell in grid_cell.
%
%       pg_variance.m, pg_kurtosis.m, pg_skewness.m
%           Calculates circular variance, kurtosis, skewness of grid_cell
%           azimuths
%
%       pg_meanaz.m
%           Calculates mean azimuth of grid_cell stroke-station paths
%
%       pg_diffcross.m
%           Calculates difference from trailing mean of stroke-station path
%           crossings in grid_crossings.  Takes as input grid_crossings and
%           meanlength (number of 10-minute time bins), outputs d_gridcross
%           and mm_gridcross.  E.g. for meanlength = 6, d_gridcross is the
%           difference of stroke-station path crossings from hourly
%           trailing mean, and mm_gridcross is that hourly trailing mean.
%
%       pg_attencontour.m
%           Calculates attenuation contours in f_gridcross, with
%           f_gridcross = grid_crossings./mm_gridcross; i.e. the fraction
%           of stroke-station path crossings relative to the [hourly]
%           trailing mean.  Requires inputs: 
%               f_gridcross 
%               [ss_lat, ss_lon] :  coordinates of subsolar point for date
%                                   range
%               cspec            :  attenuation contour thresholds
%           Outputs:
%               [latc, lonc]     :  coordinates of small-circular
%                                   attenuation contours, 
%                                   100 x length(cspec) x length(ss_lat)
%               maxrad           :  maximum radius of attenuation contour,
%                                   length(ss_lat) x length(cspec)
%
%       subsolar.m
%           Quickly calculates subsolar point for input date range.
%           Low-accuracy.
%
% OUTPUTS:
%       grid_crossings*.mat
%           180 x 360 x 144 matrix of grid_crossings, i.e. number of
%           stroke-station paths traversing 180 x 360 lat-lon grid location
%           for 144 10-minute time bins.
%
%       d_gridcross*.mat
%           180 x 360 x 144 matrix of d_gridcross, i.e. difference from
%           trailing mean of grid_crossings.  For meanlength = 6, this is
%           an hourly trailing mean; therefore d_gridcross is the
%           difference of the current grid_crossings from from the last
%           hour trailing mean.
%
%       mm_gridcross*.mat
%           180 x 360 x 144 matrix of gridcross_mm, i.e. the moving mean of
%           grid_crossings.  For meanlength = 6, this is an hourly mean.
%
%       *_attencont_lat.mat, *_attencont_lon.mat
%           100 x length(cspec) x 144 matrix of latitude/longitude points
%           defining attenuation contours.  Each contour has 100 points,
%           and there are length(cspec) [usually 3] contours for each of
%           144 10-minute time bins.
%
%       *_attencont_maxrad.mat
%           144 x length(cspec) matrix of maximum radii of attenuation
%           contours.  There are length(cspec) [usually 3] contours for
%           each of 144 10-minute time bins.  This is called the "maximum"
%           radius because the attenuation function is not monotonic, so
%           these radii are of the contours that first meet the attenuation
%           thresholds defined in cspec.
%
%       gc_kurt_all*.mat
%           180 x 360 x 144 matrix of gc_kurt, i.e. circular kurtosis of
%           grid_crossings' azimuthal distribution.  Each of 144 frames
%           represents stroke-station path crossings during the 10-minute
%           window in each strokelist file.
% 
%       gc_skew_all*.mat
%           180 x 360 x 144 matrix of gc_skew, i.e. circular skewness of
%           grid_crossings' azimuthal distribution.  Each of 144 frames
%           represents stroke-station path crossings during the 10-minute
%           window in each strokelist file.
%
%       gc_var_all*.mat
%           180 x 360 x 144 matrix of gc_var, i.e. circular variance of
%           grid_crossings' azimuthal distribution.  Each of 144 frames
%           represents stroke-station path crossings during the 10-minute
%           window in each strokelist file.

%% Input parameters:

% Enter start and stop APfile dates (inclusive).
starttime = floor(pathlist(2,1));
stoptime = starttime + 1;

% Enter date range for subsolar point calculator
%ss_date = datevec(starttime);
%ss_year = ss_date(1);
%ss_month = ss_date(2);
%ss_day = ss_date(3);
%[ss_lat,ss_lon] = subsolar(ss_year,ss_month,ss_day,0,10:10:1440,0);

% Enter attenuation contour thresholds (i.e. fraction of grid_crossings to mm_gridcross)
%cspec = [.5,.4,.3];

% Enter number of time bins (e.g. 144 10-minute time bins per day)
frames = 144;

%% Initialization

minute_bin_edges = linspace(starttime,stoptime,frames+1);

grid_crossings = zeros(180,360,frames);

%gc_variance = zeros(180,360,frames);
%gc_kurtosis = zeros(180,360,frames);
%gc_skewness = zeros(180,360,frames);
%gc_meanaz = zeros(180,360,frames);

%% gridcell, gridcross, azimuthal statistics
for m = 1:frames
    
    filestr = datestr(minute_bin_edges(m),'yyyymmddHHMM');
    %filenum = str2double(filestr);
    pathfile = sprintf('pathlist_lite_10m_%s.mat',filestr);
    pathlist = importdata(pathfile);
    % check that strokefile is non-empty
    if isempty(pathlist)
        gridcross = NaN*ones(180,360);
        msg = sprintf('Path list %s was empty, wrote NaNs to grid_crossings!',filestr);
        
        fid = fopen('nanLog.txt', 'a');
        if fid == -1
            error('Cannot open log file.');
        end
        fprintf(fid, '%s: %s\n', datestr(now, 0), msg);
        fclose(fid);

    else
        gridcell = pg_gridcell(pathlist);
        gridcross = pg_gridcross(gridcell);
        msg = sprintf('Completed run %s',filestr);
    end

    grid_crossings(:,:,m) = gridcross;
        
%     [gc_var, ~] = pg_variance(gridcell);
%     gc_variance(:,:,m) = gc_var;
%     
%     [gc_kurt, ~] = pg_kurtosis(gridcell);
%     gc_kurtosis(:,:,m) = gc_kurt;
%     
%     [gc_skew, ~] = pg_skewness(gridcell);
%     gc_skewness(:,:,m) = gc_skew;    
% 
%     [gc_maz] = pg_meanaz(gridcell);
%     gc_meanaz(:,:,m) = gc_maz;
    
    % append to log file
    %msg = sprintf('Completed run %s',filestr);
    fid = fopen('pgLog.txt', 'a');
    if fid == -1
        error('Cannot open log file.');
    end
    fprintf(fid, '%s: %s\n', datestr(now, 0), msg);
    fclose(fid);
    
end

%% diffcross, f_gridcross, attenuation contours
[~, mm_gridcross] = pg_diffcross(grid_crossings, 6); %if desired, "~" --> "d_gridcross"


%f_gridcross = grid_crossings./mm_gridcross;

%[latc,lonc,maxrad] = pg_attencontour(dB_gridcross,ss_lat,ss_lon,cspec);

%% save everything
daystr = datestr(starttime, 'yyyymmdd');

savefile_gc = sprintf('gridstats/grid_crossings_10m_%s.mat',daystr);
save(savefile_gc,'grid_crossings');

%savefile_d = sprintf('d_gridcross_10m_%s.mat',daystr);
%save(savefile_d,'d_gridcross');

savefile_mm = sprintf('gridstats/mm_gridcross_10m_%s.mat',daystr);
save(savefile_mm,'mm_gridcross');

%save('20201129_attencont_lat.mat','latc');
%save('20201129_attencont_lon.mat','lonc');
%save('20201129_attencont_maxrad.mat','maxrad');

%save('gc_var_10m_20201129.mat','gc_variance');
%save('gc_kurt_10m_20201129.mat','gc_kurtosis');
%save('gc_skew_10m_20201129.mat','gc_skewness');
%save('gc_maz_10m_20201129.mat','gc_meanaz');

end