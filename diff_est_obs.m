close all;clear;clc;
%%
load('Atlantic_cruises_with_c13.mat')

 [cruiseno,cruisename] = grp2idx(expocode);
 
 c13(c13==-9999 |c13==-999)=NaN;

   load('monthlyinsituco2mlo.mat')
 
xco2 = NaN(size(year)); 

for i = 1:length(year)
    matched_row = monthlyinsituco2mlo(monthlyinsituco2mlo.Yr == year(i) & monthlyinsituco2mlo.Mn == month(i), :);
    if ~isempty(matched_row)
        xco2(i) = matched_row.CO2; 
    end
end
 
  % adjustment
c13(expocode=="06MT19970707")=c13(expocode=="06MT19970707")+0.05;
c13(expocode=="06MT19970815")=c13(expocode=="06MT19970815")+0.05;
c13(expocode=="06MT20040311")=c13(expocode=="06MT20040311")+0.03;
c13(expocode=="316N19970815")=c13(expocode=="316N19970815")+0.05;
c13(expocode=="33MW19910711")=c13(expocode=="33MW19910711")+0.04;
c13(expocode=="33RO19980123")=c13(expocode=="33RO19980123")+0.03;
c13(expocode=="33RO20050111")=c13(expocode=="33RO20050111")-0.10;
c13(expocode=="33RO20200321")=c13(expocode=="33RO20200321")+0.07;
c13(expocode=="64TR19900417")=NaN;
c13(expocode=="58GS20150410")=c13(expocode=="58GS20150410")+0.18;

% not considered cruises
c13(expocode=="06MT20110405")=NaN;
c13(expocode=="18DL20150710")=NaN;
c13(expocode=="29GD20120910")=NaN;
c13(expocode=="33LG20060321")=NaN;
c13(expocode=="33LG20090916")=NaN;
c13(expocode=="35A320031214")=NaN;
c13(expocode=="49NZ20031106")=NaN;
c13(expocode=="740H20180228")=NaN;
c13(expocode=="74JC20181103")=NaN;

salinity(salinityf~=2 & salinity~=6)=NaN;
aou(aouf~=2 & aouf~=6)=NaN;
nitrate(nitratef~=2 & nitratef~=6)=NaN;
silicate(silicatef~=2 & silicatef~=6)=NaN;
tco2(tco2f~=2 & tco2f~=6)=NaN;
talk(talkf~=2 & talk~=6)=NaN;
cfc12(cfc12f~=2 & cfc12f~=6)=NaN;
c13(c13f~=2 & c13f~=6)=NaN;

%% 
% training dataset
% alldata.vars=[longitude, latitude, depth, maxsampdepth, temperature, salinity, nitrate, silicate, tco2, talk,  c13];
alldata.vars=[longitude, latitude, depth, maxsampdepth, temperature, salinity, aou, nitrate, silicate, tco2, xco2, c13];
a = double(alldata.vars);
a(a<-900) = nan;
alldata.vars = a;
ivalid = find(~isnan(sum(double(alldata.vars),2)));
data_valid = alldata.vars(ivalid,:);

features=data_valid(:,1:11);
targets=data_valid(:,12);

crno=cruiseno(ivalid); 
cruise_ids = unique(crno); 
    
X_test = features(crno == 25 | crno == 28, :); 
Y_test = targets(crno == 25 | crno == 28, :); 

%%
% load('pred_eff_fin.mat')
mf = matfile('pred_eff_fin.mat');
pre_test = mf.pre_test; 
% Y_test=mf.Y_test;
%% %% --- figure layout ---
fig = figure('Units','inches','Position',[1 1 9 6]);

left_margin = 0.05; right_margin = 0.17; top_margin = 0.05; btm_margin = 0.10;
fig_margin_h = 0.08; fig_margin_v = 0.03;

map_w = 0.4; map_h = 1 - top_margin - btm_margin;
map_pos = [left_margin, btm_margin-0.05, map_w, map_h];

right_w = 0.355; right_h = (map_h - 2*fig_margin_v)/3;
ax1_pos = [left_margin, btm_margin, map_w, map_h];              
ax2_pos = [left_margin+map_w+fig_margin_h+0.025, btm_margin+2*(right_h+fig_margin_v), right_w, right_h]; 
ax3_pos = [left_margin+map_w+fig_margin_h+0.025, btm_margin+right_h+fig_margin_v, right_w, right_h];     
ax4_pos = [left_margin+map_w+fig_margin_h+0.025, btm_margin, right_w, right_h];                             

ax1 = axes('Position',ax1_pos);
m_proj('Equidistant cylindrical','lons',[-80 20],'lat',[-65 70]);
[cs,h] = m_etopo2('contourf',[-7000:50:0],'edgecolor','none');
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('box','fancy','tickdir','in','linest','--','xaxislocation','top',...
    'Linewidth',1.5,'layer','top','Fontsize',12,'Fontname','Times New Roman');
caxis([-6000 0]); 
load depthmap;colormap(ax1,depthmap);
c = colorbar('Fontsize',12,'Fontname','Times New Roman'); 
set(get(c,'label'),'String','Depth (m)','Fontsize',14,'Fontname','Times New Roman');
hold on
m_plot(X_test(:,1), X_test(:,2),'ko','MarkerSize',4,'MarkerEdgeColor','k','MarkerFaceColor','k')
hold off

ax2 = axes('Position',ax2_pos);
sigma_min = min(Y_std_test);
sigma_max = max(Y_std_test);
sigma_norm = (Y_std_test - sigma_min) / (sigma_max - sigma_min);
marker_sizes = 10 - 9 * sigma_norm;  
scatter(X_test(:,2), X_test(:,3), marker_sizes, pre_test, 'filled');
colormap(ax2, turbo); 
caxis([0.4 2])
c2 = colorbar(ax2);
pos = get(c2,'Position');
pos(1) = pos(1) + 0.07;   
pos(3) = pos(3) * 0.5;     
set(c2, 'Position', pos);
% set(c2, 'Position', get(c2,'Position') .* [1 1 0.6 1]);  
set(get(c2,'label'),'String','\delta^{13}C_{est} (‰)', ...
    'FontSize',12,'FontName','Times New Roman');

set(gca,'YDir','reverse'); 
grid on; box on;
hold on
basevalue = 6000;area(X_test(:,2),X_test(:,4),basevalue,'FaceColor',[0.5 0.5 0.5])
set(gca,'Fontsize',12,'XLim',[-60 65],'YLim',[0 6000],'Fontname','Times New Roman')
xticks([]);

ax3 = axes('Position',ax3_pos);
scatter(X_test(:,2),X_test(:,3),10,Y_test,'filled')
colormap(ax3,turbo); caxis([0.4 2]);
c3 = colorbar(ax3); 
% set(c3, 'Position', get(c3,'Position') .* [1 1 0.6 1]);  
pos = get(c3,'Position');
pos(1) = pos(1) + 0.07;   
pos(3) = pos(3) * 0.5;    
set(c3, 'Position', pos);
set(get(c3,'label'),'String','\delta^{13}C_{obs} (‰)','Fontsize',12,'Fontname','Times New Roman');
set(gca,'ydir','reverse');  box on;
hold on
basevalue = 6000;area(X_test(:,2),X_test(:,4),basevalue,'FaceColor',[0.5 0.5 0.5])
set(gca,'Fontsize',12,'XLim',[-60 65],'YLim',[0 6000],'Fontname','Times New Roman')
xticks([]);

ax4 = axes('Position',ax4_pos);
scatter(X_test(:,2), X_test(:,3), marker_sizes, pre_test-Y_test,'filled');
colormap(ax4,othercolor('BuDRd_12')); caxis([-0.25 0.25])
c4 = colorbar(ax4); 
% set(c4, 'Position', get(c4,'Position') .* [1 1 0.6 1]);  
pos = get(c4,'Position');
pos(1) = pos(1) + 0.07;   
pos(3) = pos(3) * 0.5;    
set(c4, 'Position', pos);
set(get(c4,'label'),'String','\delta^{13}C_{est} - \delta^{13}C_{obs} (‰)','Fontsize',12,'Fontname','Times New Roman');
set(gca,'ydir','reverse'); box on;
hold on
basevalue = 6000;area(X_test(:,2),X_test(:,4),basevalue,'FaceColor',[0.5 0.5 0.5])
set(gca,'xtick',[-60:20:65],'xticklabel',{'60°S','40°S','20°S','0°','20°N','40°N','60°N'})
set(gca,'Fontsize',12,'XLim',[-60 65],'YLim',[0 6000],'Fontname','Times New Roman')
xlabel('Latitude','Fontsize',14,'Fontname','Times New Roman');

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 9 5.6])
print(gcf, '-dtiff', '-r600', 'Fig4_diff_est_obs.tiff');
%%
mean(pre_test-Y_test)
std(pre_test-Y_test)
