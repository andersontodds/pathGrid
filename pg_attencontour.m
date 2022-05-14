function [latc,lonc,maxr] = pg_attencontour(data_gridcross, ss_lat, ss_lon, cspec)
% pg_attencontour.m
% 22 January 2019
%
% Quantifies attenuation effect of solar flares on the Earth-ionosphere
% waveguide using following assumptions:
%   1.  Attenuation region is small-circular, i.e. has no azimuthal
%       dependence
%   2.  Effect is centered on subsolar point
%
% INPUTS:
%       data_gridcross: 180x360xN double
%           Statistics gridded on 180x360 frames.  E.g.,
%           fraction from hourly trailing mean of stroke-station path
%           crossings, but other data could be used.
%
%       ss_lat, ss_lon: vector of lengt h N double
%           Latitude and longitude of subsolar point, i.e. center of
%           attenuation region.
%       
%       cspec: vector of length M double
%           Specifies number and conditions for attenuation contours. Each
%           value of cspec specifies the condition that must be met by
%           diff_mean in order to break out of the contouring loop.  cspec
%           values can be in any order, but will be sorted into descending
%           order.  The default condition specified is the mean fraction
%           from hourly trailing mean of stroke-station path crossings.
%           E.g. for contours of 50%, 40% and 30% of hourly trailing mean
%           path crossings, cspec = [.5 .4 .3] or any permutation thereof.
%
% OUTPUTS:
%       latc, lonc: 100xMxN double
%           Lat/lon coordinates of attenuation contours.  Each contour has
%           100 lat/lon points, and M contours are returned as determined
%           by cspec.  Each N set of M contours refers to a specific time.

lons = -180:1:179;
lats = -90:1:89;
[long,latg] = meshgrid(lons,lats);

cspec = sort(cspec,'descend');

latc = ones(100,length(cspec),length(ss_lat));
lonc = ones(100,length(cspec),length(ss_lat));

maxr = zeros(length(ss_lat),length(cspec));

for n = 1:length(ss_lat)
    
    latc(:,:,n) = latc(:,:,n).*ss_lat(n);
    lonc(:,:,n) = lonc(:,:,n).*ss_lon(n);
    
    [dist, az] = distance(latg,long,ss_lat(n),ss_lon(n));
    
    data_med = 1;
    r = 0;
    
    for m = 1:length(cspec)
        
        while data_med > cspec(m)
            
            in_rad = (dist <= (90-r));
            in = in_rad.*1;
            in(in == 0) = NaN;
            
            data_in = data_gridcross(:,:,n).*in;
            data_med = median(data_in(:),'omitnan');
            
            maxr(n,m) = 90-r;
            
            r = r + 1;
            
%             [latc(:,m,n),lonc(:,m,n)] = scircle1(ss_lat(n),ss_lon(n),90-r);
%             
%             in_l = inpolygon(long,latg,lonc(:,m,n),latc(:,m,n));
%             in = in_l.*1;
%             in(in == 0) = NaN;
%             
%             diff_in = f_gridcross(:,:,n).*in;
%             
%             diff_mean = mean(diff_in(:),'omitnan');
%             
%             maxr(n,m) = 90-r;
%             
%             r = r + 1;
%             
        end
        
        [latc(:,m,n),lonc(:,m,n)] = scircle1(ss_lat(n),ss_lon(n),90-r);
        
    end

end

end