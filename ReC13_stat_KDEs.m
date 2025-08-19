close all;clear;clc;
% load data
 % load('F:\North_Atlantic\Machine_Learning\Atlantic_c13_all_cruises.mat')

% load('GLODAPv2.2023_Atlantic_Ocean_with_ReC13.mat')
load('GLODAPv2.2023_Atlantic_Ocean.mat')
load('reconstruceted_c13_GLODAPv2.2023.mat')

ReC13=reconstructed_c13;
ReC13f=reconstructed_c13f;
%%
valid_idx = find(~isnan(G2c13) & ~isnan(ReC13));
valid_idy = find((G2c13f==2 | G2c13f==6) & ReC13f==2);

obs_vals = G2c13(valid_idy);
pred_vals = ReC13(valid_idy);

R = corr(obs_vals, pred_vals);
R2 = 1 - sum((obs_vals - pred_vals).^2) / sum((obs_vals - mean(obs_vals)).^2);
MSE = mean((obs_vals - pred_vals).^2);
RMSE = sqrt(mean((obs_vals - pred_vals).^2));
MAE = mean(abs(obs_vals - pred_vals));
MBE = mean(obs_vals - pred_vals);  

%%
valid_obs = find(~isnan(G2c13) & (G2c13f==2 | G2c13f==6));
valid_pred = find(~isnan(ReC13) & ReC13f==2);

if isempty(valid_obs) || isempty(valid_pred)
    error('No valid data points found.');
end

obs = G2c13(valid_obs);
pred = ReC13(valid_pred);

bw = 0.1;  % 手动带宽

% % KDE 估计 + 添加轻微噪声（防止重复值影响）
% pred_jittered = pred + randn(size(pred)) * 0.01;
% 
% [x1, f1] = ksdensity(obs, 'Bandwidth', bw);
% [x2, f2] = ksdensity(pred_jittered, 'Bandwidth', bw);
% 
f_obs = ksdensity(obs, obs, 'Bandwidth', bw);
f_pred = ksdensity(pred, pred, 'Bandwidth', bw);

% % 统一计算 KDE 在同一 x 网格上（便于比较）
% xgrid = linspace(-0.5, 2.5, 400);   % 统一的 x 网格（可按需调整范围与点数）
% [f_obs_grid, x_obs_grid] = ksdensity(obs, xgrid, 'Bandwidth', bw, 'Function', 'pdf');
% [f_pred_grid, x_pred_grid] = ksdensity(pred, xgrid, 'Bandwidth', bw, 'Function', 'pdf');
% 
% % 计算归一化直方图（pdf）
% binwidth = 0.1;
% edges = -0.5:binwidth:2.5;
% [counts_obs, ~] = histcounts(obs, edges, 'Normalization', 'pdf');
% [counts_pred, ~] = histcounts(pred, edges, 'Normalization', 'pdf');
% centers = edges(1:end-1) + binwidth/2;

%%
num_bins = 100;
N=length(valid_idy);
[counts, centers] = hist3([pred_vals, obs_vals], 'Nbins', [num_bins, num_bins]);
counts(counts == 0) = NaN; % 避免零导致归一化问题
counts_norm = (counts - nanmin(counts(:))) / (nanmax(counts(:)) - nanmin(counts(:)));

colors = zeros(N,1);
for i = 1:N
    [~, xi] = min(abs(centers{1} - pred_vals(i)));
    [~, yi] = min(abs(centers{2} - obs_vals(i)));
    if isnan(counts_norm(xi, yi))
        colors(i) = 0;
    else
        colors(i) = counts_norm(xi, yi);
    end
end


%%
figure
axes('position', [0.09 0.12 0.42 0.85])  
scatter(pred_vals, obs_vals, 5, colors, 'filled');
colormap(hot);
c=colorbar('Fontsize',10,'Fontname','Times New Roman');
set(get(c,'label'),'string','Normalized Data Sample Density','Fontname','Times New Roman','fontsize',10)

hold on;
% 1:1 线
lims = [-0.2, 2.5];
plot(lims, lims, 'k-', 'LineWidth', 1);

% % 回归线
% coeffs = polyfit(pred_vals, obs_vals, 1);
% x_fit = linspace(min(pred_vals), max(pred_vals), 100);
% y_fit = polyval(coeffs, x_fit);
% plot(x_fit, y_fit, 'b--', 'LineWidth', 1.5);

% 指标文本
stats_text = sprintf(['R² = %.2f\nRMSE = %.3f\nMAE = %.3f\nMBE = %.3f\nN = %d'], ...
    R2, RMSE, MAE, MBE, N);
text(0.649, 0.178, stats_text, ...
    'Units', 'normalized', 'FontSize', 8, ...
    'FontName', 'Times New Roman', 'EdgeColor', 'k');
text(-0.12, 2.33, '(a)',  'FontSize', 12, ...
    'FontName', 'Times New Roman');

% 轴与标题设置
xlabel('\delta^{13}C_{Rec} (‰)', 'FontName','Times New Roman', 'FontSize', 10);
ylabel('\delta^{13}C_{Obs} (‰)', 'FontName','Times New Roman', 'FontSize', 10);
% title('Observed vs. Predicted \delta^{13}C with Density Coloring', ...
%     'FontName','Times New Roman', 'FontSize', 16);
set(gca, 'FontSize', 10, 'FontName', 'Times New Roman');
xlim(lims); ylim(lims);
axis square; box on; grid on;

%
axes('position', [0.62 0.18 0.35 0.73])  
hold on
h_kde_pred = scatter(pred, f_pred, 6, 'r', 'filled', 'MarkerFaceAlpha', 0.5);
h_kde_obs = scatter(obs, f_obs, 6, 'b', 'filled', 'MarkerFaceAlpha', 0.5);
ylabel('Estimated Density (‰^{-1})');
ylim([-0.05, 1.8])

xlabel('\delta^{13}C (‰)');
xlim([-0.5, 2.5])
h_legend=legend([h_kde_pred, h_kde_obs], ...
       {'Rec \delta^{13}C','Obs \delta^{13}C'}, 'FontSize', 8, 'FontName', 'Times New Roman');
h_legend.ItemTokenSize = [8, 8];

grid on; box on;
set(gca, 'FontSize', 10, 'FontName', 'Times New Roman');

text(-0.38, 1.675, '(b)',  'FontSize', 12, ...
    'FontName', 'Times New Roman');

set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 6.5 2.8]);
print(gcf, '-dtiff', '-r600', 'Fig5_ReC13vsObsC13');

%%
% Relative Error (%)=MAE / Mean of Observations​ × 100%
Relative_Error=MAE/mean(obs); 