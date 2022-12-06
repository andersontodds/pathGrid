% mlat_sferic_stats.m
% Todd Anderson
% 3 December 2022
%
% Find gridcell locations in magnetic latitude bins, and plot statistics of
% these.  Try other filters like day/night, land/sea,
% perpendicularity-weighted number of paths threshold

% TODO:
% smaller regions
% get _sm5 options working

year = 2022;
month = 11;
day = 07;

% load quietavg gtd and gc
gtd_quietavg = importdata("data/sferic_grouptimediff_10m_202211_quietavg.mat");
gc_quietavg =  importdata("data/sferic_gridcrossings_10m_202211_quietavg.mat");

gtd_quiet_sm5 = zeros(size(gtd_quietavg));
gc_quiet_sm5 = zeros(size(gc_quietavg));
for i = size(gtd_quiet_sm5,3)
    gtd_quiet_sm5(:,:,i) = smooth2(gtd_quietavg(:,:,i), 5);
    gc_quiet_sm5(:,:,i) = smooth2(gc_quietavg(:,:,i), 5);
end

gtd_quietavg_sm5 = importdata("data/sferic_grouptimediff_10m_202211_quietavg_sm5.mat");
gc_quietavg_sm5 =  importdata("data/sferic_gridcrossings_10m_202211_quietavg_sm5.mat");

% for day = 1:28

    gtdfile = sprintf("data/sferic_grouptimediff_gridcross_10m_%04g%02g%02g.mat", year, month, day);
    perpfile = sprintf("data/sferic_perp_gridcross_10m_%04g%02g%02g.mat", year, month, day);
    gcfile = sprintf("data/sferic_gridcrossings_10m_%04g%02g%02g.mat", year, month, day);
    gtd = importdata(gtdfile);
    perp = importdata(perpfile);
    gc = importdata(gcfile);
    
    gcpw = gc.*perp;
    gcpw_threshold = 1;
    
    mlatmesh = importdata("mlatmesh.mat");
    lsi = importdata("../landseaice/LSI_maskonly.mat");
%     [lonmesh, latmesh] = meshgrid(-179.5:179.5, -89.5:89.5);
    % region filters
    % North America
    %na_lat = [45 85];
%     na_lon = [-150 -90];
%     in_region = lonmesh > na_lon(1) & lonmesh < na_lon(2);% & latmesh > na_lat(1) & latmesh < na_lat(2);
    
    time_edge = linspace(datenum(year,month,day), datenum(year, month, day+1), size(gtd,3)+1);
    time_face = time_edge(2:end) - (time_edge(2) - time_edge(1));
    
    mlatrange = [50 70];
    mlat_bin_width = 1;
    mlat_bin_edges = mlatrange(1)-(mlat_bin_width/2):mlat_bin_width:mlatrange(2)+(mlat_bin_width/2);
    
    colors = crameri('-lajolla', length(mlat_bin_edges)+1);
    colors = colors(2:end-1, :);
    
    figure(4)
    hold off
    
    gtd_mean = zeros(size(gtd, 3), length(mlatrange));
    gtd_quiet_mean = zeros(size(gtd, 3), length(mlatrange));
    gtd_mean_qd = zeros(size(gtd, 3), length(mlatrange));
    for i = 1:length(mlat_bin_edges)-1
        grid_in_bin = mlatmesh > mlat_bin_edges(i) & mlatmesh < mlat_bin_edges(i+1);
        for j = 1:size(gtd, 3)
            gtd_frame = gtd(:,:,j);
            gtd_quietavg_frame = gtd_quietavg(:,:,j);
            gc_frame = gc(:,:,j);
            gc_quietavg_frame = gc_quietavg(:,:,j);
            gcpw_above_threshold = gcpw(:,:,j) > gcpw_threshold;
            % mean gtd over mlat bin, accounting for different number of paths
            % crossing each grid location
            totalgc = sum(gc_frame(grid_in_bin & gcpw_above_threshold));
            totalgc_quiet = sum(gc_quietavg_frame(grid_in_bin & gcpw_above_threshold));
            gtd_mean(j,i) = sum(gtd_frame(grid_in_bin & gcpw_above_threshold).*gc_frame(grid_in_bin & gcpw_above_threshold)/totalgc, "omitnan");
            gtd_quiet_mean(j,i) = sum(gtd_quietavg_frame(grid_in_bin & gcpw_above_threshold).*gc_quietavg_frame(grid_in_bin & gcpw_above_threshold)/totalgc_quiet, "omitnan");
            gtd_mean_qd(j,i) = gtd_mean(j,i) - gtd_quiet_mean(j,i);
            % mean of grid locations in mlat bin, not accounting for number of paths crossing each location    
    %         gtd_mean(j,i) = mean(gtd_frame(grid_in_bin & gcpw_above_threshold), "omitnan"); 
        end
    
%         plot(datetime(time_face, "ConvertFrom","datenum"), gtd_mean(:,i), '-', "Color", colors(i,:))
        plot(datetime(time_face, "ConvertFrom","datenum"), gtd_quiet_mean(:,i), '-', "Color", colors(i,:))        
%         plot(datetime(time_face, "ConvertFrom","datenum"), gtd_mean_qd(:,i), '-', "Color", colors(i,:))
        hold on
    end
    
    ylabel("\omega_0^2/2c (s m^{-1})")
%     ylim([0.025 0.125])
    ylim([-0.1 0.1])
    title("average \omega_0^2/2c at different magnetic latitudes")
    
%     figname = sprintf("figures/mean_gtd_mlat_%04g%02g%02g.jpg", year, month, day);
%     saveas(gcf, figname);

% end
