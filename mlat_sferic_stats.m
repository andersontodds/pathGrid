% mlat_sferic_stats.m
% Todd Anderson
% 3 December 2022
%
% Find gridcell locations in magnetic latitude bins, and plot statistics of
% these.  Try other filters like day/night, land/sea,
% perpendicularity-weighted number of paths threshold

% TODO:
% smaller regions
%   filter by local time (LT) using solarhourangle
%   magnetic local time filter requires B field model (i.e. project MLT at equator, L-shell to geodetic grid)

% quiet days: November [6, 10, 12, 14, 15, 16, 17, 19, 21, 22, 23, 24]

c = 299792458; % m/s

year = 2022;
month = 11;
% day = 11;

% load quietavg gtd and gc
gtdavg_quiet = importdata("data/sferic_grouptimediff_10m_202211_quietavg.mat");
gc_quiet =  importdata("data/sferic_total_gridcrossings_10m_202211_quietavg.mat");
std_quiet = importdata("data/sferic_std_grouptimediff_10m_202211_quietavg.mat");
% gtd_quietavg_sm5 = importdata("data/sferic_grouptimediff_10m_202211_quietavg_sm5.mat");
% gc_quietavg_sm5 =  importdata("data/sferic_gridcrossings_10m_202211_quietavg_sm5.mat");

% generated quietavg_sm5 if needed
% gtd_quiet_sm5 = zeros(size(gtd_quietavg));
% gc_quiet_sm5 = zeros(size(gc_quietavg));
% for i = 1:size(gtd_quiet_sm5,3)
%     gtd_quiet_sm5(:,:,i) = smooth2(gtd_quietavg(:,:,i), 5);
%     gc_quiet_sm5(:,:,i) = smooth2(gc_quietavg(:,:,i), 5);
% end
%
% gtd_quietavg_sm5 = gtd_quiet_sm5;
% gc_quietavg_sm5 = gc_quiet_sm5;
% save("data/sferic_grouptimediff_10m_202211_quietavg_sm5.mat", "gtd_quietavg_sm5");
% save("data/sferic_gridcrossings_10m_202211_quietavg_sm5.mat", "gc_quietavg_sm5");
% gtd_quietavg_sm5 = importdata("data/sferic_grouptimediff_10m_202211_quietavg_sm5.mat");
% gc_quietavg_sm5 =  importdata("data/sferic_gridcrossings_10m_202211_quietavg_sm5.mat");

for day = 22

    gtdfile = sprintf("data/sferic_grouptimediff_gridcross_10m_%04g%02g%02g.mat", year, month, day);
    perpfile = sprintf("data/sferic_perp_gridcross_10m_%04g%02g%02g.mat", year, month, day);
    gcfile = sprintf("data/sferic_gridcrossings_10m_%04g%02g%02g.mat", year, month, day);
    stdfile = sprintf("data/sferic_std_grouptimediff_gridcross_10m_%04g%02g%02g.mat", year, month, day);
    gtd = importdata(gtdfile);
    perp = importdata(perpfile);
    gc = importdata(gcfile);
    std = importdata(stdfile);
    
    gcpw = gc.*perp;
    gcpw_threshold = 1;
    
    poesfile = sprintf("../poes-checker/data/poes_combined_%04g%02g%02g.mat", year, month, day);
    poes = importdata(poesfile);

    mlatmesh = importdata("mlatmesh.mat");
    lsi = importdata("../landseaice/LSI_maskonly.mat");
    [lonmesh, latmesh] = meshgrid(-179.5:179.5, -89.5:89.5);
    LTlims = [19 5];
    lonlims = [-50 0];

    % longitude filter
    if lonlims(1) < lonlims(2)
        grid_in_lon = lonmesh > lonlims(1) & lonmesh < lonlims(2);
    elseif lonlims(1) > lonlims(2)
        grid_in_lon = lonmesh > lonlims(1) | lonmesh < lonlims(2);
    else
        error("check lonlims!");
    end

    % region filters
    % North America
    %na_lat = [45 85];
%     na_lon = [-150 -90];
%     in_region = lonmesh > na_lon(1) & lonmesh < na_lon(2);% & latmesh > na_lat(1) & latmesh < na_lat(2);
    
    time_edge = linspace(datenum(year,month,day), datenum(year, month, day+1), size(gtd,3)+1);
    time_face = time_edge(2:end) - (time_edge(2) - time_edge(1));
    
    mlatrange = [50 70];
    mlat_bin_width = 5;
%     mlat_bin_edges = mlatrange(1)-(mlat_bin_width/2):mlat_bin_width:mlatrange(2)+(mlat_bin_width/2); % cell-registered bins
    mlat_bin_edges = mlatrange(1):mlat_bin_width:mlatrange(2); % grid-registered bins
    
    colors = crameri('-lajolla', length(mlat_bin_edges)+1);
    colors = colors(2:end-1, :);
    
    h = figure(6);
    h.Position = [-1000 -200 882 684];
    hold off
    tiledlayout(2,1, "TileSpacing","compact","Padding","compact")
    h1 = nexttile;
    h2 = nexttile;

    gtd_mean = zeros(size(gtd, 3), length(mlatrange));
    gtd_quiet_mean = zeros(size(gtd, 3), length(mlatrange));
    gtd_mean_qd = zeros(size(gtd, 3), length(mlatrange));
    gtd_std_bin = zeros(size(gtd, 3), length(mlatrange));
    gtd_std_quiet_bin = zeros(size(gtd, 3), length(mlatrange)); % requires calculating std map of combined quiet days
    wo_mean = zeros(size(gtd_mean));
    wo_quiet_mean = zeros(size(gtd_mean));
    wo_mean_qd = zeros(size(gtd_mean));
    wo_std_bin = zeros(size(gtd_mean));
    %wo_std_quiet_bin = zeros(size(gtd_mean));
    h_mean = zeros(size(gtd_mean));
    h_quiet_mean = zeros(size(gtd_mean));
    h_mean_qd = zeros(size(gtd_mean));
    h_std_bin = zeros(size(gtd_mean));
    %h_st_quiet_bin = zeros(size(gtd_mean));
    for i = 1:length(mlat_bin_edges)-1
        % filter mlat and other meshgrid parameters
        grid_in_mlat = mlatmesh > mlat_bin_edges(i) & mlatmesh < mlat_bin_edges(i+1);
        for j = 1:size(gtd, 3)

            % local time filter
            LTmesh = localsolartime(time_face(j), lonmesh, 0);
            %LTmesh(LTmesh < 0) = LTmesh(LTmesh < 0) + 24;
            LTmesh = mod(LTmesh, 24);
            if LTlims(1) < LTlims(2)
                grid_in_LT = LTmesh > LTlims(1) & LTmesh < LTlims(2);
            elseif LTlims(1) > LTlims(2)
                grid_in_LT = LTmesh > LTlims(1) | LTmesh < LTlims(2);
            else
                error("check LTlims!");
            end

            gtd_frame = gtd(:,:,j);
            gtd_quietavg_frame = gtdavg_quiet(:,:,j);
            gc_frame = gc(:,:,j);
            gc_quiet_frame = gc_quiet(:,:,j);
            gcpw_above_threshold = gcpw(:,:,j) > gcpw_threshold;
            gtd_std_frame = std(:,:,j);
            gtd_std_quiet_frame = std_quiet(:,:,j);

            % combine grid filters
            grid_in_bin = grid_in_mlat & grid_in_LT & gcpw_above_threshold;

            % mean gtd over mlat bin, accounting for different number of paths
            % crossing each grid location
%             totalgc = sum(gc_frame(grid_in_bin));
%             totalgc_quiet = sum(gc_quietavg_frame(grid_in_bin));
%             gtd_mean(j,i) = sum(gtd_frame(grid_in_bin).*gc_frame(grid_in_bin)/totalgc, "omitnan");
%             gtd_quiet_mean(j,i) = sum(gtd_quietavg_frame(grid_in_bin).*gc_quietavg_frame(grid_in_bin)/totalgc_quiet, "omitnan");
%             gtd_mean_qd(j,i) = gtd_mean(j,i) - gtd_quiet_mean(j,i);

            % test overallmeanstd method
            [~, gtd_mean(j,i), gtd_std_bin(j,i)] = overallmeanstd(gc_frame(grid_in_bin), gtd_frame(grid_in_bin), gtd_std_frame(grid_in_bin)); % replace std inputs with file data
            [~, gtd_quiet_mean(j,i), gtd_std_quiet_bin(j,i)] = overallmeanstd(gc_quiet_frame(grid_in_bin), gtd_quietavg_frame(grid_in_bin), gtd_std_quiet_frame(grid_in_bin));
            % probably have to do unit conversions before calculating
            % combined std
            % mean of grid locations in mlat bin, not accounting for number of paths crossing each location    
    %         gtd_mean(j,i) = mean(gtd_frame(grid_in_bin & gcpw_above_threshold), "omitnan"); 
        end
        
        gtd_mean_qd(:,i) = gtd_mean(:,i) - gtd_quiet_mean(:,i);

        % convert gtd_mean, gtd_quiet_mean, gtd_mean_qd to cutoff
        % frequency, ionosphere effective height
        wo_mean(:,i) = sqrt(2*c*gtd_mean(:,i));
        wo_quiet_mean(:,i) = sqrt(2*c*gtd_quiet_mean(:,i));
        wo_mean_qd(:,i) = wo_mean(:,i) - wo_quiet_mean(:,i);
        wo_std_bin(:,i) = sqrt(2*c*(gtd_mean(:,i) + gtd_std_bin(:,i))) - wo_mean(:,i);
%         wo_quiet_std(:,i)
        
        h_mean(:,i) = c*pi./(wo_mean(:,i));
        h_quiet_mean(:,i) = c*pi./(wo_quiet_mean(:,i));
        h_mean_qd(:,i) = h_mean(:,i) - h_quiet_mean(:,i);
        h_std_bin(:,i) = c*pi./(wo_mean(:,i) + wo_std_bin(:,i)) - h_mean(:,i);
        

        poes_in_bin = poes.mag_lat_foot > mlat_bin_edges(i) & poes.mag_lat_foot < mlat_bin_edges(i+1);
%         poes_in_bin = abs(poes.mag_lat_foot) > mlat_bin_edges(i) & abs(poes.mag_lat_foot) < mlat_bin_edges(i+1);

        axes(h1);
        hold on
%         plot(datetime(time_face, "ConvertFrom","datenum"), gtd_mean(:,i), '-', "Color", colors(i,:), "LineWidth", 2)
%         plot(datetime(time_face, "ConvertFrom","datenum"), gtd_mean(:,i) + gtd_std_bin(:,i), ':', "Color", colors(i,:), "LineWidth", 1)
%         plot(datetime(time_face, "ConvertFrom","datenum"), gtd_mean(:,i) - gtd_std_bin(:,i), ':', "Color", colors(i,:), "LineWidth", 1)
%         plot(datetime(time_face, "ConvertFrom","datenum"), gtd_quiet_mean(:,i), '-', "Color", colors(i,:), "LineWidth", 1)
%         plot(datetime(time_face, "ConvertFrom","datenum"), gtd_quiet_mean(:,i) + gtd_std_quiet_bin(:,i), ':', "Color", colors(i,:), "LineWidth", 2)
%         plot(datetime(time_face, "ConvertFrom","datenum"), gtd_quiet_mean(:,i) - gtd_std_quiet_bin(:,i), ':', "Color", colors(i,:), "LineWidth", 2)
%         plot(datetime(time_face, "ConvertFrom","datenum"), gtd_mean_qd(:,i), '-', "LineWidth", 1)

%         plot(datetime(time_face, "ConvertFrom","datenum"), wo_mean(:,i)./(2*pi*1E3), '-', "LineWidth", 1)
%         plot(datetime(time_face, "ConvertFrom","datenum"), wo_mean(:,i)./(2*pi*1E3) + wo_std_bin(:,i)./(2*pi*1E3), ':', "Color", colors(i,:))
%         plot(datetime(time_face, "ConvertFrom","datenum"), wo_mean(:,i)./(2*pi*1E3) - wo_std_bin(:,i)./(2*pi*1E3), ':', "Color", colors(i,:))

%         plot(datetime(time_face, "ConvertFrom","datenum"), h_mean(:,i)./1E3, '-', "Color", colors(i,:), "LineWidth", 1)
%         plot(datetime(time_face, "ConvertFrom","datenum"), h_mean_qd(:,i)./1E3, '-', "Color", colors(i,:), "LineWidth", 1)
%         plot(datetime(time_face, "ConvertFrom","datenum"), h_mean_qd(:,i)./1E3 + h_std_bin(:,i)./1E3, ':', "Color", colors(i,:), "LineWidth", 1)
%         plot(datetime(time_face, "ConvertFrom","datenum"), h_mean_qd(:,i)./1E3 - h_std_bin(:,i)./1E3, ':', "Color", colors(i,:), "LineWidth", 1)
        plot(datetime(time_face, "ConvertFrom","datenum"), h_quiet_mean(:,i)./1E3, '-', "LineWidth", 1)

        

        axes(h2);
        semilogy(datetime(poes.time(poes_in_bin), "ConvertFrom","datenum"), poes.mep_ele_tel0_flux_e3(poes_in_bin), '.', "MarkerSize", 10);
        hold on
    end
    
    axes(h1);
    yline(0, ":k", LineWidth=1)
    h1 = gca;
    h1.ColorOrder = colors;
    h1.FontSize = 12;
    y1 = ylabel("\omega_0^{ 2}/2c (rad^2 s^{-1} m^{-1})");
%     y1 = ylabel("\Deltah_i (km)");
    y1.FontSize = 12;
%     ylim([-0.02 0.02])
%     ylim([-30 30])
ylim([120 150])
    xlim([datetime(year, month, day), datetime(year, month, day+1)])
%     t1 = title("difference of nightside \omega_0^{ 2}/2c from quiet day baseline");
%     t1 = title("difference of nightside ionosphere height from quiet day baseline");
    t1 = title("nightside ionosphere height");
%     t1 = title("average \omega_0^{ 2}/2c of November quiet days at different magnetic latitudes");
    t1.FontSize = 15;

    axes(h2);
    h2.ColorOrder = colors;
    h2.FontSize = 12;
    ylim([1E2 1E7])
    xlim([datetime(year, month, day), datetime(year, month, day+1)])
    y2 = ylabel("electron flux (cm^{-2} sr^{-1} keV^{-1} s^{-1})");
    y2.FontSize = 12;
    t2 = title("0-degree E3 electron flux at different magnetic latitudes, all satellites");
    t2.FontSize = 15;

    cb = colorbar;
    cb.Colormap = colors;
    cb.Layout.Tile = 'east';
    cb.Label.String = "magnetic latitude (\circ)";
    tickspace = 5;
%     cb.Ticks =
%     ((1:tickspace:mlatrange(2)+1-mlatrange(1))-0.5)./(mlatrange(2)+1-mlatrange(1));
%     % cell-registered bins
    cb.Ticks = ((mlatrange(1):tickspace:mlatrange(2))-mlatrange(1))./(mlatrange(2)-mlatrange(1)); % grid-registred bins
    cb.TickLabels = mlatrange(1):tickspace:mlatrange(2);

    cb.Label.FontSize = 15;
    cb.FontSize = 12;
    
    % save
%     figname = sprintf("figures/lanl/iono_h_quietavg_poes_mlat_%04g%02g%02g_smaller.jpg", year, month, day);
%     exportgraphics(h, figname, Resolution=300);

end
