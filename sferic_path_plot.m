% sferic_path_plot.m
% Todd Anderson
% December 6 2022
%
% Additional plots for AGU 2022, based on sferic_paths.m


%% 3. day - quiet mean
% 
run_start = datenum(2022, 11, 11);
daystr = string(datestr(run_start, "yyyymmdd"));
gtdfile = sprintf("data/sferic_grouptimediff_gridcross_10m_%s.mat", daystr);
perpfile = sprintf("data/sferic_perp_gridcross_10m_%s.mat", daystr);
gcfile = sprintf("data/sferic_gridcrossings_10m_%s.mat", daystr);
gtd = importdata(gtdfile);
perp = importdata(perpfile);
gc = importdata(gcfile);
gtd_quietavg = importdata("data/sferic_grouptimediff_10m_202211_quietavg.mat");
gtd_quietavg_sm5 = importdata("data/sferic_grouptimediff_10m_202211_quietavg_sm5.mat");

gcpw = gc.*perp;

%% plot
% whole day average: plot day_avg
% month average: plot gc_cavg(:,:,k); manually input desired frame k or
% loop over k

times = linspace(run_start, run_start+1, 145);
timestring = string(datestr(times, "HH:MM:SS"));
datestring = string(datestr(run_start, "mmmm dd yyyy"));

[lonmesh, latmesh] = meshgrid(-179.5:179.5,-89.5:89.5);
% lsi = importdata("../landseaice/LSI_mask.mat");
% lsimask = interp2(lsi.lon_mesh, lsi.lat_mesh, lsi.LSI, lonmesh, latmesh, "nearest");

coastlines = importdata('coastlines.mat');
coastlat = coastlines.coastlat;
coastlon = coastlines.coastlon;
geoidrefvec = [1,90,-180];

gcpw_threshold = 1;

latlim = [40 80];
lonlim = [-180 -50];

% daymean = zeros(size(gtd, 3),1);
% nightmean = zeros(size(gtd, 3),1);
% landmean = zeros(size(gtd, 3),1);
% seamean = zeros(size(gtd, 3),1);
% icemean = zeros(size(gtd, 3),1);

% for k = 1:size(gtd_cavg,3)
for k = 1:size(gtd, 3)
% for k = 144
%     c3plot = mean(c3pl_cavg, 3,'omitnan');
%     c3plot = smooth2(gtd_cavg(:,:,k), 5);
%     pplot = pg_cavg(:,:,k);
%     c3plot = gtd_avg;
    gtd_frame = gtd(:,:,k);
    gtd_quietavg_sm5_frame = gtd_quietavg_sm5(:,:,k);
    gcpw_frame = gcpw(:,:,k);
    gcpw_above_threshold = gcpw_frame > gcpw_threshold; 
    gtd_frame(~gcpw_above_threshold) = NaN;
    gtd_quietavg_sm5_frame(~gcpw_above_threshold) = NaN;
    c3plot = gtd_frame - gtd_quietavg_sm5_frame ;
    
    % terminator test
    [sslat, sslon] = subsolar(times(k));
    night = distance(sslat, sslon, latmesh, lonmesh, 'degrees') > 90;
    %c3plot(night) = 10;
    
%     daymean(k) = mean(c3plot(~night), "all", "omitnan");
%     nightmean(k) = mean(c3plot(night), "all", "omitnan");
%     landmean(k) = mean(c3plot(lsimask == 1), "all", "omitnan");
%     seamean(k) = mean(c3plot(lsimask == -1), "all", "omitnan");
%     icemean(k) = mean(c3plot(lsimask == 0), "all", "omitnan");

    figure(1);
    hold off
%     t = tiledlayout(2,2, "TileSpacing","compact", "Padding", "compact");
    
%     nexttile([1,2])
%     worldmap("World")
    worldmap(latlim, lonlim)
    geoshow(c3plot, geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color","black");
    contourm(latmesh, lonmesh, mlatmesh, 50:70, "k"); % mlat contours
    
%     set(gca,'ColorScale','log');
    crameri('-hawaii');
%     caxis([0 1]);
%     crameri('tokyo');%,'pivot',1); % requires "crameri" colormap toolbox
%     caxis([0 0.2]);
    caxis([0 0.05]);


%     nexttile
%     %worldmap("World");
%     worldmap([60 90],[-180 180])
%     geoshow(c3plot, geoidrefvec, "DisplayType","texturemap");
%     hold on
%     geoshow(coastlat, coastlon, "Color","black");
%     
%     xlabel("Latitude");
%     ylabel("Longitude");
%     title("");
% %     set(gca,'ColorScale','log');
%     crameri('-hawaii');
% %     caxis([0 1]);
% %     crameri('tokyo');%,'pivot',1); % requires "crameri" colormap toolbox
% %     caxis([0 0.2]);
%     caxis([0 0.05]);
% 
%     
%     nexttile
%     worldmap([-90 -60],[-180 180])
%     geoshow(c3plot, geoidrefvec, "DisplayType","texturemap");
%     hold on
%     geoshow(coastlat, coastlon, "Color","black");
%     
%     xlabel("Latitude");
%     ylabel("Longitude");
%     title("");
% %     set(gca,'ColorScale','log');
%     crameri('-hawaii');
% %     caxis([0 1]);
% %     crameri('tokyo'); % requires "crameri" colormap toolbox
% %     caxis([0 0.2]);
%     caxis([0 0.05]);
    cb = colorbar;
%     cb.Layout.Tile = 'east';
    cb.Label.String = "rad^2 s^{-1} m^{-1}";
    cb.Label.FontSize = 12;
    
    
    
%     titlestr = sprintf("Mean sferic c3/path length \n %s %s-%s", ...
%         datestring, timestring(k), timestring(k+1));
    titlestr = sprintf("Average sferic c3/path length \n November quiet days %s-%s", ...
       timestring(k), timestring(k+1));
    title(titlestr);

%     gifname = sprintf('animations/sferic_mean_gtd_%s.gif', daystr);
%     gifname = 'animations/sferic_gtd_quietmean_202211_sm5.gif';
%     if k == 1
%         gif(gifname);
%     else
%         gif;
%     end

end
