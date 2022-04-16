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

%% get YYYYMMDD date strings by flare class

x_ds = datestr(time_dn(x_ind), "YYYYmmDD");
x_dsu = string(unique(x_ds,'rows'));
x_day = str2double(x_dsu);

m_ds = datestr(time_dn(m_ind), "YYYYmmDD");
m_dsu = string(unique(m_ds,'rows'));
m_day = str2double(m_dsu);

x_APname = compose("AP%s.mat",x_dsu);
m_APname = compose("AP%s.mat",m_dsu);

x_cu = char(x_dsu);
x_year = string(x_cu(:,1:4));

m_cu = char(m_dsu);
m_year = string(m_cu(:,1:4));

x_filepath = strings(size(x_APname));
for i = 1:length(x_APname)
    switch x_year(i)
        case {'2017','2018','2019'}
            x_filepath(i) = compose("/flash5/wd2/APfiles/%s/%s",x_year(i),x_APname(i));
        case {'2020','2021','2022'}
            x_filepath(i) = compose("/flash5/wd2/APfiles/%s",x_APname(i));
    end
end

m_filepath = strings(size(m_APname));
for i = 1:length(m_APname)
    switch m_year(i)
        case {'2017','2018','2019'}
            m_filepath(i) = compose("/flash5/wd2/APfiles/%s/%s",m_year(i),m_APname(i));
        case {'2020','2021','2022'}
            m_filepath(i) = compose("/flash5/wd2/APfiles/%s",m_APname(i));
    end
end

unique_x_days = ~ismember(x_filepath, m_filepath);
xm_filepath = sort(cat(1,m_filepath,x_filepath(unique_x_days)));

save('flarelist_APfilenames_20170101-20220331.mat', "x_filepath", "m_filepath", "xm_filepath");
save('flarelist_days_20170101-20220331.mat', "x_day", "m_day");

