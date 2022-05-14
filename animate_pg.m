function animate_pg(day)
% animate_pg.m
% Todd Anderson
% April 15, 2022
%
% Function version of pathGrid_video.m. Takes binned grid_crossings,
% d_gridcross, mm_gridcross, etc.; and generated texturemap animation.
%

%% Initialize

switch class(day)
    case 'double'
        if day > 7e5 && day < 8e5
            daynum = day;
            daystr = datestr(daynum, 'YYYYmmDD');
        elseif day > 19900000 && day < 21000000
            daystr = num2str(day);
            daynum = datenum(daystr, 'YYYYmmDD');
        else
            error('Cannot identify day format!')
        end
    case 'string'
        daystr = day;
        daynum = datenum(day, 'YYYYmmDD');
    otherwise
        error('Cannot identify day format!');
end

starttime = daynum;
stoptime = daynum + 1;

grid_crossings = importdata(sprintf('grid_crossings_10m_%s.mat', daystr));
gridcross_mm = importdata(sprintf('mm_gridcross_10m_%s.mat',daystr));
frames = size(grid_crossings, 3);
time_10m = linspace(starttime,stoptime,frames+1);


% gridcross_mmed = importdata('mmed_gridcross_10m_20170906.mat');
% gridcross_dmed = importdata('dmed_gridcross_10m_20170906.mat');
coastlines = importdata('coastlines.mat');
coastlat = coastlines.coastlat;
coastlon = coastlines.coastlon;
geoidrefvec = [1,90,-180];

filename = sprintf('%s_10m_dB_gc_add001_mm_smed10_surf',daystr);

v = VideoWriter([filename '.avi'],'Motion JPEG AVI');
v.Quality = 100;
open(v);

K(frames) = struct('cdata',[],'colormap',[]);


%% Plot frames

dB_gridcross = pg_dbcross(grid_crossings, gridcross_mm);

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
    %colormap(parula);
    colormap(redblue);
    hold off;
    %geoshow(log10(grid_crossings(:,:,t)),geoidrefvec,'DisplayType','texturemap');
    geoshow(dB_gridcross_sm12(:,:,t), geoidrefvec, 'DisplayType','surface');
    hold on;
    geoshow(coastlat, coastlon, 'Color', 'black');
    %geoshow(stll(:,1),stll(:,2),'DisplayType','Point');

    cb = colorbar('southoutside');
    label = cb.Label;
    label.String = ['Attenuation of stroke-station path crossings (dB) ',datestr(time_10m(t))];
    label.FontSize = 10;
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

end
