close all;clear;clc;
% load('F:\North_Atlantic\Machine_Learning\pred_eff.mat')
load('pred_eff_fin.mat')

%%
C13est=validationPredictions;
C13obs=Y_train;

% [train_obs, train_est, validation_obs, validation_est] = splitData(C13obs, C13est, 0.8);
% [train_obs, train_est, validation_obs, validation_est, train_idx, val_idx] = splitData(C13obs, C13est, 0.8);

rng(0); % 为可重复性
N = length(C13obs);
idx = randperm(N);

N_train = round(0.8 * N);
train_idx = idx(1:N_train);
val_idx   = idx(N_train+1:end);

train_obs = C13obs(train_idx);
train_est = C13est(train_idx);

validation_obs = C13obs(val_idx);
validation_est = C13est(val_idx);

% 对应标准差
Y_std_train_orig = Y_std_train;  

Y_std_train_new = Y_std_train_orig(train_idx);        % 新训练集 std
Y_std_validation = Y_std_train_orig(val_idx);        % 验证集 std

test_obs=Y_test;
test_est=pre_test;

% Statistical metrics
R2_train = 1 - sum((train_obs - train_est).^2) / sum((train_obs - mean(train_obs)).^2);
MSE_train = mean((train_obs - train_est).^2);
RMSE_train = sqrt(mean((train_obs - train_est).^2));
MAE_train = mean(abs(train_obs - train_est));
MBE_train = mean(train_obs - train_est);  

R2_validation = 1 - sum((validation_obs - validation_est).^2) / sum((validation_obs - mean(validation_obs)).^2);
MSE_validation = mean((validation_obs - validation_est).^2);
RMSE_validation = sqrt(mean((validation_obs - validation_est).^2));
MAE_validation = mean(abs(validation_obs - validation_est));
MBE_validation = mean(validation_obs - validation_est); 

R2_test = 1 - sum((test_obs - test_est).^2) / sum((test_obs - mean(test_obs)).^2);
MSE_test = mean((test_obs - test_est).^2);
RMSE_test = sqrt(mean((test_obs - test_est).^2));
MAE_test = mean(abs(test_obs - test_est));
MBE_test = mean(test_obs - test_est); 
 
%%  
top_margin = 0.08;      % 顶部边距（图形窗口高度的比例）
btm_margin = 0.19;       % 底部边距
left_margin = 0.068;     % 左侧边距
right_margin = 0.08;     % 右侧边距（预留颜色条空间）
fig_margin = 0.068;      % 子图间距
row = 1;                % 行数
col = 3;                % 列数

% 计算子图尺寸
% Calculate figure height and width according to rows and cols 
fig_h = (1- top_margin - btm_margin - (row-1) * fig_margin) / row;
fig_w = (1 - left_margin - right_margin - (col-1) * fig_margin) / col;


datasets = {
    {train_est, train_obs, 'Training Set', R2_train, RMSE_train, MAE_train, MBE_train},
    {validation_est, validation_obs, 'Validation Set', R2_validation, RMSE_validation, MAE_validation, MBE_validation},
    {test_est, test_obs, 'Test Set', R2_test, RMSE_test, MAE_test, MBE_test}
};

%%

figure
n = 0;
for i = 1:col
    pos_left = left_margin + (i-1)*(fig_w + fig_margin);
    pos_bottom = btm_margin + (row-1)*(fig_h + fig_margin); 
    pos = [pos_left, pos_bottom, fig_w, fig_h];
    ax = axes('Position', pos, 'FontName','Times New Roman'); 
    
    est_data = datasets{i}{1};
    obs_data = datasets{i}{2};
    title_str = datasets{i}{3};
    R2 = datasets{i}{4};
    RMSE = datasets{i}{5};
    MAE = datasets{i}{6};
    MBE = datasets{i}{7};
    
    n_points = length(est_data);
    
    % --- 获取标准差 ---
    switch i
        case 1
            std_data = Y_std_train_new;
        case 2
            std_data = Y_std_validation;
        case 3
            std_data = Y_std_test;
    end
    
    % --- 计算密度颜色 ---
    num_bins = 100;
    [counts, centers] = hist3([est_data, obs_data], 'Nbins', [num_bins, num_bins]);
    counts_norm = (counts - min(counts(:))) / (max(counts(:)) - min(counts(:))); 
    colors = zeros(n_points,1);
    for j = 1:n_points
        [~, xi] = min(abs(centers{1} - est_data(j)));
        [~, yi] = min(abs(centers{2} - obs_data(j)));
        colors(j) = counts_norm(xi, yi);
    end

    hold on
     % --- 1:1 line ---
    lims = [-0.5, 3];
    plot(ax, lims, lims, 'k-', 'LineWidth', 1);
    % % --- 绘制 ±1σ 灰色带 ---
    % x_fill = [lims, fliplr(lims)];
    % y_fill = [lims + mean(std_data), fliplr(lims - mean(std_data))];
    % % fill(ax, x_fill, y_fill, [0.7 0.7 0.7], 'FaceAlpha',0.3, 'EdgeColor','none');

    % h_sigma = fill(ax, x_fill, y_fill, [0.7 0.7 0.7], ...
    %                'FaceAlpha',0.3, 'EdgeColor','none');
    % 
    % % --- 添加 legend ---
    % legend([h_scatter, h_sigma], {'Samples', '\pm 1\sigma'}, 'Location','southeast','Fontsize',8.5,'Fontname','Times New Roman');
    
    % --- 绘制 ±1σ 灰色带，并返回句柄 ---
    sigma_mean = mean(std_data); % 平均标准差
    x_fill = [lims, fliplr(lims)];
    y_fill = [lims + sigma_mean, fliplr(lims - sigma_mean)];
    h_sigma = fill(ax, x_fill, y_fill, [0.7 0.7 0.7], 'FaceAlpha',0.5, 'EdgeColor','none');

    % --- ±95% CI 灰带 ---
    CI_factor = 1.96;
    y_fill_CI = [lims + CI_factor*sigma_mean, fliplr(lims - CI_factor*sigma_mean)];
    h_CI = fill(ax, x_fill, y_fill_CI, [0.6 0.6 0.6], 'FaceAlpha',0.3, 'EdgeColor','none');
    
    % --- 绘制散点（颜色表示密度） ---
    h_scatter=scatter(est_data, obs_data, 3, colors, 'filled', 'Parent', ax);
    colormap(ax, hot(num_bins)); 
    caxis([0 1]); % density normalized 0~1

    
    
    % --- legend ---
    h_legend = legend([h_scatter, h_sigma, h_CI], ...
           {'Samples', ...
            sprintf('\\pm 1\\sigma (%.2f‰)', sigma_mean), ...
            sprintf('95%% CrI (\\pm %.2f‰)', CI_factor*sigma_mean)}, ...
           'Units','normalized', 'Location','southeast','FontSize',7.2,'FontName','Times New Roman');
    h_legend.ItemTokenSize = [8, 8]; % [width, height] 单位为像素
    % set(h_legend, 'Position', [0.62 0.05 0.35 0.18]); 

    stats_text = sprintf('R²=%.2f\nRMSE=%.3f\nMAE=%.3f\nMBE=%.3f\nN = %d', ...
        R2, RMSE, MAE, MBE, n_points);
    text(0.022, 0.798, stats_text, 'Units','normalized','FontSize',8.5,'FontName','Times New Roman',...
        'EdgeColor','k','BackgroundColor','w','Parent',ax);
    
    xlabel(ax,'\delta^{13}C_{est} (‰)');
    ylabel(ax,'\delta^{13}C_{obs} (‰)');
    title(ax,['(' char(97+i-1) ') ' title_str], 'FontSize',10);
    set(ax,'XLim',[-0.2 2.5],'YLim',[-0.2 2.5],'Fontsize',10,'Fontname','Times New Roman');
    grid(ax,'on'); grid(ax,'minor'); box on;
end

% --- Colorbar for density (all panels) ---
axes('position', [1-right_margin-fig_margin-0.05, btm_margin, 0.18, 1-(top_margin+btm_margin)]);
axis off;
c = colorbar('Fontsize',10,'Fontname','Times New Roman');
set(get(c,'label'),'string','Normalized Data Sample Density','Fontname','Times New Roman','fontsize',10)
colormap(hot); 

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 2.6])
print(gcf, '-dtiff', '-r600', 'Fig3_est_obs.tiff');