function pathgrid_sferic(pathlist_sferic, stationName)
% pathgrid_sferic.m
% Todd Anderson
% November 14, 2022
%
% TODO: consider incorporating the sferic functionality into standard
% pathgrid.m with varargin, etc.
%
% Function version of pathGrid_10m.m, pathGrid_fullstats_10m, etc.
% Requires inputs contain sferic information, and computes outputs
% including statistics of sferic information.
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
%       pathlist_sferic: matrix of stroke-station pairs generated by 
%           getsferics.m from APfiles and Sfiles.
%
% FUNCTIONS:
%       pg_gridcell_sferic.m
%           Converts strokelist to 180 x 360 cell array 'grid_cell'.  These
%           outputs are large (total 1-day = several GB), so each grid_cell
%           is cleared before proceding to next 10-minute strokelist.
%
%       pg_gridcross.m
%           Converts grid_cell to grid_crossings, a 180 x 360 matrix.  Each
%           element is the length of the corresponding cell in grid_cell.
%
%       pg_perpendicularity.m
%           Calculates circular perpendicularity of azimuths of sferic
%           propagation paths at each grid location.  See function for
%           definition and details if needed.
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
%       perp_gridcross_*.mat
%           180 x 360 x 144 matrix of perpendicularity of grid crossing
%           azimuths.
%
%       sferic_c1_gricross_*.mat, sferic_c2_gricross_*.mat, sferic_c3_gricross_*.mat
%           180 x 360 x 144 matrix of mean dispersion fit parameters of 
%           sferics crossing grid locations
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

%% Input parameters:

% Enter start and stop APfile dates (inclusive).
starttime = floor(pathlist_sferic(2,1));
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

switch nargin
    case 2
        stationName = sprintf('_%s',stationName);
    case 1
        stationName = "";
end


%% Initialization

minute_bin_edges = linspace(starttime,stoptime,frames+1);

grid_crossings = zeros(180,360,frames);
perp_gridcross = zeros(180,360,frames);
sferic_c1_gricross = zeros(180,360,frames);
sferic_c2_gricross = zeros(180,360,frames);
sferic_c3_gricross = zeros(180,360,frames);

%gc_variance = zeros(180,360,frames);
%gc_kurtosis = zeros(180,360,frames);
%gc_skewness = zeros(180,360,frames);
%gc_meanaz = zeros(180,360,frames);

%% gridcell, gridcross, azimuthal statistics
for m = 1:frames
    
    filestr = datestr(minute_bin_edges(m),'yyyymmddHHMM');
%     % uncomment the two lines below if you want to load pathlist from pathfiles
%     pathfile = sprintf('pathlist_lite_10m_%s.mat',filestr);
%     pathlist = importdata(pathfile);

    in_frame = pathlist_sferic(:,1) > minute_bin_edges(m) & pathlist_sferic(:,1) < minute_bin_edges(m+1);
    pathlist_frame = pathlist_sferic(in_frame, :);

    % check that pathlist is non-empty
    if isempty(pathlist_frame)
        gridcross = NaN*ones(180,360);
        msg = sprintf('Path list %s was empty, wrote NaNs to grid_crossings!',filestr);
        
        fid = fopen('nanLog.txt', 'a');
        if fid == -1
            error('Cannot open log file.');
        end
        fprintf(fid, '%s: %s\n', datestr(now, 0), msg);
        fclose(fid);

    else
        %gridcell = pg_gridcell(pathlist); % for 180x360 pathlist, i.e. from single-frame files
        gridcell = pg_gridcell_sferic(pathlist_frame); % for 180x360xN pathlist, i.e. directly from getpaths or from multi-frame file
        gridcross = pg_gridcross(gridcell);
        gc_perp = pg_perpendicularity(gridcell);
        [gc_c1, gc_c2, gc_c3, gc_var_c1, gc_var_c2, gc_var_c3] = pg_dispersion(gridcell);
        msg = sprintf('Completed run %s',filestr);
    end

    grid_crossings(:,:,m) = gridcross;
    perp_gridcross(:,:,m) = gc_perp;
    sferic_c1_gricross(:,:,m) = gc_c1;
    sferic_c2_gricross(:,:,m) = gc_c2;
    sferic_c3_gricross(:,:,m) = gc_c3;
    sferic_var_c1_gricross(:,:,m) = gc_var_c1;
    sferic_var_c2_gricross(:,:,m) = gc_var_c2;
    sferic_var_c3_gricross(:,:,m) = gc_var_c3;

        
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
    fid = fopen('pgSfericLog.txt', 'a');
    if fid == -1
        error('Cannot open log file.');
    end
    fprintf(fid, '%s: %s\n', datestr(now, 0), msg);
    fclose(fid);
    
end

%% diffcross, f_gridcross, attenuation contours
%[~, mm_gridcross] = pg_diffcross(grid_crossings, 6); %if desired, "~" --> "d_gridcross"


%f_gridcross = grid_crossings./mm_gridcross;

%[latc,lonc,maxrad] = pg_attencontour(dB_gridcross,ss_lat,ss_lon,cspec);

%% save everything
daystr = datestr(starttime, 'yyyymmdd');

savefile_gc = sprintf('gridstats/sferic_gridcrossings_10m_%s%s.mat',daystr,stationName);
save(savefile_gc,'grid_crossings');

%savefile_d = sprintf('d_gridcross_10m_%s.mat',daystr);
%save(savefile_d,'d_gridcross');

% savefile_mm = sprintf('gridstats/mm_gridcross_10m_%s%s.mat',daystr,stationName);
% save(savefile_mm,'mm_gridcross');

savefile_perp = sprintf('gridstats/sferic_perp_gridcross_10m_%s%s.mat',daystr,stationName);
save(savefile_perp, 'perp_gridcross');

savefile_c1 = sprintf("gridstats/sferic_c1_gridcross_10m_%s%s.mat", daystr, stationName);
save(savefile_c1, "sferic_c1_gricross");

savefile_c2 = sprintf("gridstats/sferic_c2_gridcross_10m_%s%s.mat", daystr, stationName);
save(savefile_c2, "sferic_c2_gricross");

savefile_c3 = sprintf("gridstats/sferic_c3_gridcross_10m_%s%s.mat", daystr, stationName);
save(savefile_c3, "sferic_c3_gricross");

savefile_vc1 = sprintf("gridstats/sferic_var_c1_gridcross_10m_%s%s.mat", daystr, stationName);
save(savefile_vc1, "sferic_var_c1_gricross");

savefile_vc2 = sprintf("gridstats/sferic_var_c2_gridcross_10m_%s%s.mat", daystr, stationName);
save(savefile_vc2, "sferic_var_c2_gricross");

savefile_vc3 = sprintf("gridstats/sferic_var_c3_gridcross_10m_%s%s.mat", daystr, stationName);
save(savefile_vc3, "sferic_var_c3_gricross");

end