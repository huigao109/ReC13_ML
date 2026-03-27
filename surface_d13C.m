close all; clear; clc;

load('GLODAPv2.2023_Atlantic_Ocean.mat')
load('reconstruceted_c13_GLODAPv2.2023.mat')

ReC13=reconstructed_c13;
ReC13f=reconstructed_c13f;

depth_thres = 10;
lat_bins = -80:5:80;
lat_centers = lat_bins(1:end-1)+2.5;

decades = {'1980s', '1990s', '2000s', '2010s'};
year_ranges = [1980 1990; 1990 2000; 2000 2010; 2010 2020];
colors = lines(4);

valid_obs = find(~isnan(G2c13) & (G2c13f==2 | G2c13f==6) & G2depth<=10);
valid_pred = find(~isnan(ReC13) & ReC13f==2 & G2depth<=10);

figure
% Count per decade and lat bin
obs_counts = zeros(4, length(lat_centers));
pred_counts = zeros(4, length(lat_centers));

for d = 1:4
    switch d
        case 1
            yr_range = G2year >= 1980 & G2year < 1990;
        case 2
            yr_range = G2year >= 1990 & G2year < 2000;
        case 3
            yr_range = G2year >= 2000 & G2year < 2010;
        case 4
            yr_range = G2year >= 2010 & G2year <= 2021;
    end

    % Observation
    for i = 1:length(lat_centers)
        lat_range = G2latitude >= lat_bins(i) & G2latitude < lat_bins(i+1);
        idx_obs = find(~isnan(G2c13) & (G2c13f==2 | G2c13f==6) & G2depth<=10 & yr_range & lat_range);
        obs_counts(d,i) = length(idx_obs);
    end

    % Reconstruction
    for i = 1:length(lat_centers)
        lat_range = G2latitude >= lat_bins(i) & G2latitude < lat_bins(i+1);
        idx_pred = find(~isnan(ReC13) & ReC13f==2 & G2depth<=10 & yr_range & lat_range);
        pred_counts(d,i) = length(idx_pred);
    end
end

obs_stack = obs_counts';   
pred_stack = pred_counts'; 

n_bins = size(obs_stack, 1);  

bar_width = 0.3;         
intra_gap = 0.3;           
inter_gap = 1;           
x_positions = (0:n_bins-1) * (2*bar_width + intra_gap + inter_gap);
x_obs = x_positions;               
x_pred = x_positions + bar_width + intra_gap;  

axes('position', [0.09 0.7 0.88 0.28])
hold on; box on; grid on;

h_obs = bar(x_obs, obs_stack, 'stacked', ...
    'BarWidth', bar_width, ...  
    'EdgeColor', 'none', ...
    'FaceColor', 'flat'); 

for i = 1:4
    h_obs(i).CData = colors(i,:);
end

h_pred = bar(x_pred, pred_stack, 'stacked', ...
    'BarWidth', bar_width, ...  
    'EdgeColor', 'k', ...
    'FaceColor', 'flat', ...
    'FaceAlpha', 0.3);  
for i = 1:length(h_pred)
    h_pred(i).LineWidth = 1.5; 
end

for i = 1:4
    h_pred(i).CData = colors(i,:); 
end

% hatchfill(h_pred(i),'cross','HatchAngle',45,'HatchDensity',30);

xticks([ ]);

% xlabel('Latitude (°)', 'FontSize', 14);
ylabel('Sample Count', 'FontSize', 14);

legend_items = { ...
    '1980s Observed', '1990s Observed', '2000s Observed', '2010s Observed', ...
    '1980s Reconstructed', '1990s Reconstructed', '2000s Reconstructed', '2010s Reconstructed' ...
};
h_legend=legend(legend_items, 'Location', 'northwest', 'FontSize', 12, 'FontName', 'Times New Roman','NumColumns',2);
h_legend.ItemTokenSize = [10, 10];

 axis tight;

set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
text(-5.2,650,'(a)','FontSize', 20, 'FontName', 'Times New Roman')

%%
% figure('Position', [100, 100, 1000, 900]);
axes('position', [0.09 0.40 0.88 0.28])
hold on
for d = 1:length(decades)
    decade_start = 1980 + (d-1)*10;
    decade_end = decade_start + 10;
    idx_obs = valid_obs(G2year(valid_obs) >= decade_start & G2year(valid_obs) < decade_end);
    idx_pred = valid_pred(G2year(valid_pred) >= decade_start & G2year(valid_pred) < decade_end);
    scatter(G2latitude(idx_obs), G2c13(idx_obs), 10, colors(d,:), 's', ...
        'filled', 'MarkerFaceAlpha', 0.25, 'DisplayName', [decades{d} ' Observed']);
    scatter(G2latitude(idx_pred), ReC13(idx_pred), 10, colors(d,:), 's', ...
        'MarkerEdgeAlpha', 0.25, 'DisplayName', [decades{d} ' Reconstructed']);

    obs_avg = nan(1, length(lat_centers));
    obs_std = nan(1, length(lat_centers));
    pred_avg = nan(1, length(lat_centers));
    pred_std = nan(1, length(lat_centers));

    for i = 1:length(lat_centers)
        lat_min = lat_bins(i);
        lat_max = lat_bins(i+1);

        idx_lat_obs = idx_obs(G2latitude(idx_obs) >= lat_min & G2latitude(idx_obs) < lat_max);
        if ~isempty(idx_lat_obs)
            obs_avg(i) = mean(G2c13(idx_lat_obs));
            obs_std(i) = std(G2c13(idx_lat_obs));
        end

        idx_lat_pred = idx_pred(G2latitude(idx_pred) >= lat_min & G2latitude(idx_pred) < lat_max);
        if ~isempty(idx_lat_pred)
            pred_avg(i) = mean(ReC13(idx_lat_pred));
            pred_std(i) = std(ReC13(idx_lat_pred));
        end
    end

    h1 = errorbar(lat_centers, obs_avg, obs_std, '^', ...
        'Color', 'k', 'MarkerFaceColor', colors(d,:), ...
        'MarkerSize', 6, 'CapSize', 5, 'MarkerEdgeColor', 'k', ...
        'LineWidth', 1.2,'DisplayName', [decades{d} ' Obs Mean ± SD']);

    h2 = errorbar(lat_centers, pred_avg, pred_std, 'o', ...
        'Color', 'k', 'MarkerFaceColor', colors(d,:),  ...
        'MarkerSize', 6, 'CapSize', 5, 'MarkerEdgeColor', 'k', ...
        'LineWidth', 1.2, 'DisplayName', [decades{d} ' Rec Mean ± SD']);

    uistack(h1, 'top');
    uistack(h2, 'top');
end

xlim([-80 80]);
ylim([-0.5 2.5]);
xticks(-80:10:80);
xlabel('Latitude (°)', 'FontSize', 14, 'FontName', 'Times New Roman');
ylabel('\delta^{13}C_{DIC} (‰)', 'FontSize', 14, 'FontName', 'Times New Roman');
legend('Location', 'southwest', 'FontSize', 12, 'FontName', 'Times New Roman','NumColumns',4);
grid on;
box on;
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
text(-93,2.5,'(b)','FontSize', 20, 'FontName', 'Times New Roman')

axes('position', [0.09 0.06 0.88 0.28])
hold on
for i = 1:4
    idx_obs = find(G2depth <= depth_thres & G2year >= year_ranges(i,1) & G2year < year_ranges(i,2) & ~isnan(G2c13) & (G2c13f==2 | G2c13f==6));
    idx_pred = find(G2depth <= depth_thres & G2year >= year_ranges(i,1) & G2year < year_ranges(i,2) & ~isnan(ReC13) & ReC13f==2);
    
    if ~isempty(idx_obs)
        [f, xi] = ksdensity(G2c13(idx_obs));
        plot(xi, f, '--', 'Color', colors(i,:), 'LineWidth', 1.5);
    end
    if ~isempty(idx_pred)
        [f2, xi2] = ksdensity(ReC13(idx_pred));
        plot(xi2, f2, 'Color', colors(i,:), 'LineWidth', 1.5);
    end
end
xlabel('\delta^{13}C_{DIC} (‰)')
ylabel('Estimated Density (KDE)')
% title('Kernel Density Estimation of \delta^{13}C by Decade')
% legend([decades, strcat(decades, ' Pred')], 'Location', 'northeast')
legend_items = { ...
    '1980s Observed', '1980s Reconstructed','1990s Observed',  '1990s Reconstructed', '2000s Observed', '2000s Reconstructed', ...
     '2010s Observed','2010s Reconstructed' ...
};
legend(legend_items, 'Location', 'northwest', 'FontSize', 12, 'FontName', 'Times New Roman','NumColumns',1);
grid on; box on
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman')
text(-0.805,2,'(c)','FontSize', 20, 'FontName', 'Times New Roman')

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 10 12])
print(gcf,'-dtiff','-r300','Fig_C13_Latitude_and_Distributions');
