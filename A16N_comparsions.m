close all;clear;clc;

load('GLODAPv2.2023_Atlantic_Ocean.mat')
load('reconstruceted_c13_GLODAPv2.2023.mat')

%
lat{1}=G2latitude(G2cruise==338);
lat{2}=G2latitude(G2cruise==342);
lat{3}=G2latitude(G2cruise==1041);

lat{5}=G2latitude(G2cruise==338);
lat{6}=G2latitude(G2cruise==342);
lat{7}=G2latitude(G2cruise==1041);

depth{1}=G2depth(G2cruise==338);
depth{2}=G2depth(G2cruise==342);
depth{3}=G2depth(G2cruise==1041);

depth{5}=G2depth(G2cruise==338);
depth{6}=G2depth(G2cruise==342);
depth{7}=G2depth(G2cruise==1041);

botdepth{1}=G2bottomdepth(G2cruise==338);
botdepth{2}=G2bottomdepth(G2cruise==342);
botdepth{3}=G2bottomdepth(G2cruise==1041);

botdepth{5}=G2bottomdepth(G2cruise==338);
botdepth{6}=G2bottomdepth(G2cruise==342);
botdepth{7}=G2bottomdepth(G2cruise==1041);

predicted_c13=reconstructed_c13;
predicted_c13f=reconstructed_c13f;
predicted_c13(predicted_c13f~=2)=NaN;
% non_nan_count = nnz(predicted_c13f==2);

load('A16N_2013.mat')
DELC13(DELC13_FLAG_W~=2 & DELC13_FLAG_W~=6)=NaN;

G2c13(G2c13f~=2 & G2c13f~=6)=NaN;

c13{1}=G2c13(G2cruise==338);
c13{2}=G2c13(G2cruise==342);
% c13{3}=G2c13(G2cruise==1041);
c13{3}=DELC13;

c13{5}=predicted_c13(G2cruise==338);
c13{6}=predicted_c13(G2cruise==342);
c13{7}=predicted_c13(G2cruise==1041);

non_nan_counts = zeros(1, length(c13)); 

for i = 1:length(c13)
    non_nan_counts(i) = nnz(~isnan(c13{i}(:)));
end


% load 2023 data and predict d13C
load('A16N_2023_v20250701.mat')

% calculate depth
caldep = sw_dpth(CTDPRS,LATITUDE);

year=floor(DATE/10000);
month=floor(mod(DATE,10000)/100);

load('monthlyinsituco2mlo.mat')
xco2 = NaN(size(year)); 

for i = 1:length(year)
    matched_row = monthlyinsituco2mlo(monthlyinsituco2mlo.Yr == year(i) & monthlyinsituco2mlo.Mn == month(i), :);
    if ~isempty(matched_row)
        xco2(i) = matched_row.CO2; 
    end
end

% % calculate AOU
sa=gsw_SA_from_SP(CTDSAL,CTDPRS,LONGITUDE,LATITUDE);
temp=gsw_CT_from_t(sa,CTDTMP,CTDPRS);
O2sol = gsw_O2sol(sa,temp,CTDPRS,LONGITUDE,LATITUDE);
AOU = O2sol - OXYGEN;  

AOU_FLAG_W=OXYGEN_FLAG_W;

input_2023=[LONGITUDE,LATITUDE,caldep,CTDTMP,CTDSAL,AOU,NITRAT,SILCAT,TCARBN,xco2];
a = double(input_2023);
a(a<-900) = nan;
input_2023 = a;

load('pred_eff_fin.mat')
input_2023_nor = (input_2023 - mu) ./ sigma;

pred_c13_2023 = trainedModel.predictFcn(input_2023_nor);

invalid=find(~isnan(CTDTMP) & ~isnan(CTDSAL) & (NITRAT_FLAG_W==2 | NITRAT_FLAG_W==6) ...
    & (SILCAT_FLAG_W==2 | SILCAT_FLAG_W==6) & (AOU_FLAG_W==2 | AOU_FLAG_W==6) ...
    & (TCARBN_FLAG_W==2 | TCARBN_FLAG_W==6) & STNNBR~=88 & STNNBR~=92);

pred_c13f_2023= 9 * ones(size(pred_c13_2023));
pred_c13f_2023(invalid) = 2;
count_23 = nnz(pred_c13f_2023==2);
pred_c13_2023(pred_c13f_2023~=2)=NaN;

DELC13(DELC13_FLAG_W~=2 & DELC13_FLAG_W~=6)=NaN;

lat{4}=LATITUDE;
depth{4}=caldep;
botdepth{4}=DEPTH;
c13{4}=DELC13;

lat{8}=LATITUDE;
depth{8}=caldep;
botdepth{8}=DEPTH;
c13{8}=pred_c13_2023;

%% figure
top_margin = 0.08;      
btm_margin = 0.19;       
left_margin = 0.06;     
right_margin = 0.08;     
fig_margin = 0.05;      
row = 2;                
col = 4;                

nname={'(a) 1993 observation';'(b) 2003 observation';'(c) 2013 observation';'(d) 2023 observation';...
       '(e) 1993 reconstruction';'(f) 2003 reconstruction';'(g) 2013 reconstruction';'(h) 2023 reconstruction'};

% Calculate figure height and width according to rows and cols 
fig_h = (1- top_margin - btm_margin - (row-1) * fig_margin) / row;
fig_w = (1 - left_margin - right_margin - (col-1) * fig_margin) / col;
figure
n=0;
for i = 1 : row    
    for j = 1 : col        
        % figure position: you can refer to 'help axes' to review the        
        % parameter meaning, note that original point is lower-left   
        if n<4
        position = [left_margin + (j-1)*(fig_margin+fig_w), ...           
            1- (top_margin + i * fig_h + (i-1) * fig_margin), ...           
            fig_w, fig_h];     
        else
        position = [left_margin + (j-1)*(fig_margin+fig_w), ...           
            1- (top_margin + i * fig_h + (i-1) * fig_margin)-0.03, ...           
            fig_w, fig_h];  
        end
        
        axes('position', position)       
        % draw colorful pictures...    
        n=n+1;
        scatter(lat{n},depth{n},2,c13{n},'filled')
        colormap(turbo)
        caxis([0.4 1.8]);
        hold on;
        set(gca,'ydir','reverse');
        basevalue = 6000;
        area(lat{n},botdepth{n},basevalue,'FaceColor',[0.7 0.7 0.7])
        grid on
        set(gca,'Fontsize',10,'XLim',[-5 64],'YLim',[0 6000],'Fontname','Times New Roman')
        if n>4
        set(gca,'xtick',[-10:10:65],'xticklabel',{'10°S','0°','10°N','20°N','30°N','40°N','50°N','60°N'})
        else
        set(gca,'xtick',[ ])
        end
            
%         xlabel('Latitude','Fontsize',16,'Fontname','Times New Roman');
%         ylabel('Depth (m)','Fontsize',16,'Fontname','Times New Roman');
        box on;
        text(-5, -580, nname{n}, ...
             'FontSize', 12,'FontName','Times New Roman');

        
    end
end% draw colorbar
axes('position', [1-right_margin-fig_margin-0.075, btm_margin-0.03, 0.18, 1-(top_margin+btm_margin)+0.028]);
axis off;
c=colorbar('Fontsize',12,'Fontname','Times New Roman');
set(get(c,'label'),'string','\delta^{13}C (‰)','Fontname','Times New Roman','fontsize',12)
colormap(turbo)
caxis([0.4 1.8]);

[ax1,h1]=suplabel('Latitude','x');
set(h1,'Fontsize',12,'Fontname','Times New Roman','position',[0.5 -0.08])
[ax2,h2]=suplabel('Depth (m)','y');
set(h2,'Fontsize',12,'Fontname','Times New Roman','position',[-0.002 0.5])

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 9 3.6])
% print(gcf,'-dtiff','-r600','A16N_compare_obs_pred');        

