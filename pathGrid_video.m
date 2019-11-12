% pathGrid_video.m
% 19 November 2018
%
% Takes binned grid_crossings.mat as input, generates texturemap video.
%

%% Initialize

load('grid_crossings_10m_20170906.mat');
load('mm_gridcross_10m_20170906.mat');
load('d_gridcross_10m_20170906.mat');
load coastlines;
geoidrefvec = [1,90,-180];

filename = ('20170906_10m_dB_gc_add001_mmed_smed10_surf');

v = VideoWriter([filename '.mp4'],'MPEG-4');
v.Quality = 100;
open(v);

frames = size(grid_crossings, 3);
K(frames) = struct('cdata',[],'colormap',[]);

starttime = datenum(2017,09,06,00,10,00);
stoptime = datenum(2017,09,07,00,00,00);
time_10m = linspace(starttime,stoptime,frames);


%% Plot frames

grid_crossings_add001 = grid_crossings + 0.001;
dB_gridcross = 10*log10(grid_crossings_add001./gridcross_mmed);

% find pixels with 0 s-s path crossings large trailing mean/median; set to
% minimum (e.g. -20 dB)
% dB_inf = (dB_gridcross == -Inf);
% mmed_large = (gridcross_mmed >= 5);
% dB_set = (dB_inf & mmed_large);
% dB_gridcross(dB_set) = -20;


%log_d_gridcross = sign(d_gridcross).*log10(d_gridcross./(sign(d_gridcross)));
%r_gc = grid_crossings./gridcross_mm;

% perc_d_gridcross = (d_gridcross./gridcross_mm)*100;
% perc_d_gridcross_thr = (d_gc_threshold./gc_threshold)*100;
% 
% %weight_d_gridcross = d_gridcross.*gridcross_mm;
% 
% %log_gc_sm12 = zeros(size(grid_crossings));
% 
% r_d_sm12 = zeros(size(grid_crossings));
%perc_d_gc_varw = ratio_d_gridcross_varw.*100;
%perc_d_gridcross_thr_sm12 = zeros(size(perc_d_gridcross_thr));

dB_gridcross_sm12 = zeros(size(dB_gridcross));

for t = 1:frames
    
%     r_d_sm1 = movmean(perc_d_gridcross(:,:,t),10,1,'omitnan');
%     r_d_sm2 = movmean(perc_d_gridcross(:,:,t),10,2,'omitnan');
%     r_d_sm12(:,:,t) = movmean(r_d_sm1,10,2,'omitnan');
%     %log_gc = log10(r_d_sm12);



    dB_gridcross_sm1 = movmedian(dB_gridcross(:,:,t),10,1,'omitnan');
    dB_gridcross_sm12(:,:,t) = movmedian(dB_gridcross_sm1,10,2,'omitnan');
%   d_gc_var_sm1 = movmean(abs(d_gc_var(:,:,t)),10,1,'omitnan');
%   d_gc_var_sm2 = movmean(abs(d_gc_var(:,:,t)),10,2,'omitnan');
%   d_gc_var_sm12(:,:,t) = movmean(d_gc_var_sm1,10,2,'omitnan');
%   d_gc_var_sm21 = movmean(d_gc_var_sm2,10,1,'omitnan');

    figure(1);
    colormap(jet);
    hold off;
    %geoshow(log10(grid_crossings(:,:,t)),geoidrefvec,'DisplayType','texturemap');
    geoshow(dB_gridcross_sm12(:,:,t), geoidrefvec, 'DisplayType','surface');
    hold on;
    geoshow(coastlat, coastlon, 'Color', 'black');
    %geoshow(stll(:,1),stll(:,2),'DisplayType','Point');

    cb = colorbar('southoutside');
    label = cb.Label;
    label.String = ['Power ratio of stroke-station path crossings (dB) ',datestr(time_10m(t))];
    label.FontSize = 16;
    caxis([-10 10]);
    
    % for log colorbars:
%     caxis([0 3]);
%     cb.Ticks = [0 1 2 3];
%     cb.TickLabels = {'10^0', '10^1', '10^2', '10^3'};
%     

    drawnow;
    K(t) = getframe(gcf);
    writeVideo(v,K(t));

end

close(v);
