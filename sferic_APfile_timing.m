% sferic_APfile_timing.m
% Todd Anderson
% November 09 2022
%
% Test matching sferics from Sfiles with lightning strokes from APfiles

% load Sfile -- see read_sfile.m for documentation
sfilename = "data/S-files/2021/S202107080401"; % seattle/togasea Sfile
% sfilename = "data/S-files/2022/S202211072302"; % fairbanks Sfile
sfile_values = import_sfile(sfilename);

time = sfile_values(:,1);   % UTC time in datenum format (serial date number)
mutoga = sfile_values(:,2); % UTC toga offset in microseconds
rmsAmp = sfile_values(:,3); % rms amplitude
dtoga = sfile_values(:,4);  % TOGA offset in seconds from start of waveform
c1 = sfile_values(:,5);     % dispersion fit parameters
c2 = sfile_values(:,6);     %
c3 = sfile_values(:,7);     %
Fs = sfile_values(:,8);     % sampling frequency in Hz
N = sfile_values(:,9);      % number of samples

sfile_time_sec = (time - floor(time))*86400;

sfile_time_start = min(sfile_values(:,1));
sfile_time_end = max(sfile_values(:,1));

c = 299792458; % speed of light in a vacuum (m/s)
c_eiwg = 0.9914*c; % band-averaged group velocity == propagation speed in EIWG (Dowden et al 2002)
re_km = 6371; % mean radius of the Earth in km
eps_eiwg = pi*re_km*1000/c_eiwg; % time for a sferic to travel halfway around the Earth in seconds

% get pathlist for station and time of Sfile
pathlist_day = getpaths(20210708, "sourceStation", "Seattle", "nosave", "localfile");
in_sfile_time = pathlist_day(:,1) > sfile_time_start - eps_eiwg/86400 & pathlist_day(:,1) < sfile_time_end - eps_eiwg/86400;
pathlist = pathlist_day(in_sfile_time, :);

stroke_time_sec = (pathlist(:,1) - floor(pathlist(:,1)))*86400;

% calculate distance --> propagation time between each stroke and the Sfile station
d_ss = distance(pathlist(:,2), pathlist(:,3), pathlist(:,4), pathlist(:,5), re_km); % in km
t_ss = 1000*d_ss./c_eiwg;

% check correspondence between sfile times and pathlist times

for i = 1:length(pathlist)
    [min1(i), min1_idx(i)] = min(abs((sfile_time_sec) - stroke_time_sec(i) + t_ss(i))); % nearest match between stroke time and sfile UTC time
    [min2(i), min2_idx(i)] = min(abs((sfile_time_sec + dtoga) - stroke_time_sec(i) + t_ss(i))); % nearest match between stroke time and sfile UTC time + dtoga
    [min3(i), min3_idx(i)] = min(abs((sfile_time_sec + mutoga./1E6) - stroke_time_sec(i) + t_ss(i))); % nearest match between stroke time and sfile UTC time + mutoga
    [min4(i), min4_idx(i)] = min(abs((sfile_time_sec + dtoga + mutoga./1E6) - stroke_time_sec(i) + t_ss(i))); % nearest match between stroke time and sfile UTC time + dtoga + mutoga
end

%% plot
figure(1)
hold off
plot(1:length(pathlist), min1, '.');
hold on
plot(1:length(pathlist), min2, '.');
plot(1:length(pathlist), min3, '.');
plot(1:length(pathlist), min4, '.');
ylabel("minimum time difference (s)");
xlabel("path index")
legend('Sferic UTC time', 'Sferic UTC time + dtoga', 'Sferic UTC time + mutoga', 'Sferic UTC time + dtoga + mutoga');
title('minimum time difference between APfile strokes and Sfile sferics including travel time');
