% pathGrid_animate.m
% 12 November 2018
% 
% Receives grid_cell as input, bins stroke-station paths by time, and 
% animates time series.  For a version that only outputs a binned
% grid_crossings.mat, see pathGrid_animate_savegc.m.  For a version that
% uses a binned grid_crossings.mat as input and outputs a video, see
% pathGrid_video.m.
% 

%% Initialize

%load('grid_cell_20170928.mat');

%load coastlines;


%% Operate on grid_cell

tic;

% find number of grid crossings

% mean_crossing_az = zeros(180,360);
% std_crossing_az = zeros(180,360);
% var_crossing_az = zeros(180,360);
% kurt_crossing_az = zeros(180,360);


frames = 144;
grid_crossings = zeros(180,360,frames);
%K(frames) = struct('cdata',[],'colormap',[]);

starttime = datenum(2017,09,28,00,00,00);
stoptime = datenum(2017,09,29,00,00,00);
minute_bin_edges = linspace(starttime,stoptime,frames+1);
%hour_bin_edges = linspace(starttime,stoptime,25);

%v = VideoWriter('20170910_1.mp4','MPEG-4');
%open(v);

for t = 1:frames
    for n = 1:180
        for p = 1:360
            
            
            if size(grid_cell{n,p},1) == 0
                grid_crossings(n,p,t) = 0;
            else
                grid_crossings(n,p,t) = size(grid_cell{n,p}(grid_cell{n,p}(:,2) >= minute_bin_edges(t) & grid_cell{n,p}(:,2) < minute_bin_edges(t+1)),1);
            end
            
%             if size(grid_cell{n,p},1) == 0
%                 mean_crossing_az(n,p) = NaN;
%                 std_crossing_az(n,p) = NaN;
%             else
%                 grid_az = grid_cell{n,p}(:,3);
%                 grid_az_rad = deg2rad(grid_az);
%                 
%                 mean_az_rad = circ_mean(grid_az_rad,[],1);
%                 mean_crossing_az(n,p) = rad2deg(mean_az_rad);
%                 
%                 % circular variance, st. dev are both unitless!
%                 varx = 1-sqrt(mean(sin(grid_az_rad)).^2 + mean(cos(grid_az_rad)).^2);
%                 var_crossing_az(n,p) = varx;
%                 std_crossing_az(n,p) = sqrt(2*varx);
%                 
%                 kurt_crossing_az(n,p) = circ_kurtosis(grid_az_rad,[],1);
%                 
%             end
        end
        
    end
    
%     figure(6)
%     hold off;
%     colormap('jet');
%     cmap = colormap;
%     cmap(1,:) = [1,1,1];
%     colormap(figure(6),cmap);
%     
%     geoshow(grid_crossings,[1,90,-180],'DisplayType','texturemap');
%     hold on;
%     geoshow(coastlat,coastlon,'Color','black');
%     
%     cb = colorbar('southoutside');
%     label = cb.Label;
%     label.String = ['Number of sferic crossings at grid location UTC h = ',num2str(t-1)];
%     label.FontSize = 11;
%     
%     
%     %drawnow
%     
%     K(t) = getframe(gcf);
%     writeVideo(v,K(t));
    
    
end

save('grid_crossings_10m_20170910-1_all.mat','grid_crossings');

stats_time = toc;

