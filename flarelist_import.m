% flarelist_import.m
% Todd Anderson
% April 4, 2022
%
% Read solar flare list NetCDF files (.nc), and get flare statistics and
% subsets of the list (e.g. all X-class, all M-class, ...).  Flare lists
% from GOES-16 (20170209-present) and GOES-17 (20180601-present) obtained
% from "XRS Flare Summary [16/17]" here: 
% https://www.ngdc.noaa.gov/stp/satellite/goes-r.html 

%% display file groups, dimensions, attributes, variables
filename = 'sci_xrsf-l2-flsum_g16_s20170209_e20220331_v2-1-0.nc';
%filename = 'sci_xrsf-l2-flsum_g17_s20180601_e20220331_v2-1-0.nc';

ncdisp(filename);

%% read variables from file

xrsb_flux = ncread(filename, 'xrsb_flux');
status = ncread(filename, 'status');
time = ncread(filename, 'time');
background_flux = ncread(filename, 'background_flux');
flare_class = ncread(filename, 'flare_class');
integrated_flux = ncread(filename, 'integrated_flux');
flare_id = ncread(filename, 'flare_id');

%% convert time to datenum format
% time: flare start time since January 1, 2000, 12pm; in seconds,
% neglecting leap seconds
% convert to time since January 1, 1970, 12am; in days
time_dn = time/86400 + datenum(2000, 01, 01, 12, 00, 00);

%% get subsets by flare class

class_char = zeros(size(flare_class));
for i = 1:length(flare_class)
    fc = flare_class(i);
    class_char(i) = fc{1}(1);
end

x_ind = find(class_char == 'X');
m_ind = find(class_char == 'M');
c_ind = find(class_char == 'C');

