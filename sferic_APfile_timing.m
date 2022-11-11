% sferic_APfile_timing.m
% Todd Anderson
% November 09 2022
%
% Test matching sferics from Sfiles with lightning strokes from APfiles

% load Sfile -- see read_sfile.m for documentation

sfile_values = [];

for h = 0:23
    for m = 0:59
    % sfilename = "data/S-files/2021/S202107080401"; % seattle/togasea Sfile
        sfilename = sprintf("data/S-files/2022/S20221107%02d%02d",h,m); % fairbanks Sfile
        sfile = import_sfile(sfilename);
    
        sfile_values = cat(1, sfile_values, sfile);
    end
end

time = sfile_values(:,1);   % UTC time in datenum format (serial date number)
%sfile_time_sec = sfile_values(:,2); % second of Sfile time with 1 us precision
mutoga = sfile_values(:,2); % UTC toga offset in microseconds
rmsAmp = sfile_values(:,3); % rms amplitude
dtoga = sfile_values(:,4);  % TOGA offset in seconds from start of waveform
c1 = sfile_values(:,5);     % dispersion fit parameters
c2 = sfile_values(:,6);     %
c3 = sfile_values(:,7);     %
Fs = sfile_values(:,8);     % sampling frequency in Hz
N = sfile_values(:,9);     % number of samples

sfile_dayfrac = time - floor(time);
sfile_time_sec = second(datetime(time, 'ConvertFrom', "datenum"));

sfile_time_start = min(time);
sfile_time_end = max(time);

c = 299792458; % speed of light in a vacuum (m/s)
% c_eiwg = 0.9914*c; % band-averaged group velocity == propagation speed in EIWG (Dowden et al 2002)
c_eiwg = 0.9905*c; % from James' email Nov 09 2022
re_km = 6371; % mean radius of the Earth in km
eps_eiwg = pi*re_km*1000/c_eiwg; % time for a sferic to travel halfway around the Earth in seconds

% get pathlist for station and time of Sfile
pathlist_day = getpaths(20221107, "sourceStation", "Fairbanks", "nosave", "localfile");
in_sfile_time = pathlist_day(:,1) > sfile_time_start - eps_eiwg/86400 & pathlist_day(:,1) < sfile_time_end - eps_eiwg/86400;
pathlist = pathlist_day(in_sfile_time, :);

stroke_time = pathlist(:,1);
stroke_dayfrac = stroke_time - floor(stroke_time);
stroke_time_sec = pathlist(:,7); % seconds of stroke time with ~1 us accuracy

% calculate distance --> propagation time between each stroke and the Sfile station
% d_ss = distance(pathlist(:,2), pathlist(:,3), pathlist(:,4), pathlist(:,5), re_km); % in km
d_ss = distance(pathlist(:,2), pathlist(:,3), pathlist(:,4), pathlist(:,5), referenceEllipsoid('wgs84')); % in m

t_ss = d_ss./c_eiwg;

% check correspondence between sfile times and pathlist times

min_sec         = ones(size(stroke_time_sec));
min_sec_idx     = ones(size(stroke_time_sec));
min_datenum     = ones(size(stroke_time_sec));
min_datenum_idx = ones(size(stroke_time_sec));
min_dayfrac     = ones(size(stroke_time_sec));
min_dayfrac_idx = ones(size(stroke_time_sec));

for i = 1:length(pathlist)
%     [min1(i), min1_idx(i)] = min(abs((sfile_time_sec) - (stroke_time_sec(i) + t_ss(i)))); % nearest match between stroke time and sfile UTC time
%     [min2(i), min2_idx(i)] = min(abs((sfile_time_sec + dtoga) - (stroke_time_sec(i) + t_ss(i)))); % nearest match between stroke time and sfile UTC time + dtoga
%     [min3(i), min3_idx(i)] = min(abs((sfile_time_sec + mutoga./1E6) - (stroke_time_sec(i) + t_ss(i)))); % nearest match between stroke time and sfile UTC time + mutoga
%     [min4(i), min4_idx(i)] = min(abs((sfile_time_sec + dtoga + mutoga./1E6) - (stroke_time_sec(i) + t_ss(i)))); % nearest match between stroke time and sfile UTC time + dtoga + mutoga
    
    % compare matching with datenum*86400 times (eps = 7.6 us),  (datenum - floor(datenum))*86400 times (eps = 7.3 ps), and seconds (eps = 7.1 fs)
    [min_sec(i), min_sec_idx(i)] = min(abs((sfile_time_sec + mutoga./1E6) - (stroke_time_sec(i) + t_ss(i)))); % nearest match between stroke time and sfile UTC time + mutoga
    [min_datenum(i), min_datenum_idx(i)] = min(abs((time.*86400 + mutoga./1E6) - (stroke_time(i)*86400 + t_ss(i)))); % nearest match between stroke time and sfile UTC time + mutoga
    [min_dayfrac(i), min_dayfrac_idx(i)] = min(abs((sfile_dayfrac.*86400 + mutoga./1E6) - (stroke_dayfrac(i)*86400 + t_ss(i)))); % nearest match between stroke time and sfile UTC time + mutoga
end

%% plot
figure(1)
hold off
semilogy(1:length(pathlist), min_sec, '.');
hold on
semilogy(1:length(pathlist), min_datenum, '.');
semilogy(1:length(pathlist), min_dayfrac, '.');
ylabel("minimum time difference (s)");
xlabel("path index")
legend('seconds (eps = 7.1 fs)', 'datenum*86400 s/day (eps = 7.6 us)', 'day fraction * 86400 s/day (eps = 7.3 ps)');
title('minimum time difference between APfile strokes and Sfile sferics including travel time');

% figure(2)
% hold off
% loglog(sfile_time_sec(min_sec_idx) + mutoga(min_sec_idx)./1E6, stroke_time_sec + t_ss, '.');
% hold on
% %plot(time.*86400 + mutoga./1E6, stroke_time_sec + t_ss, '.');
% loglog(sfile_dayfrac(min_dayfrac_idx).*86400 + mutoga(min_dayfrac_idx)./1E6, stroke_dayfrac.*86400 + t_ss, '.');