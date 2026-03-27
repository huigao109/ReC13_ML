close all;clear;clc;

% load data
 load('D:\carbon\North_Atlantic\Machine_Learning\Atlantic_c13_all_cruises.mat')

 c13(~(c13f==2 | c13f==6))=NaN;

 in1=find(~isnan(c13));
 lon1=longitude(in1);
 lat1=latitude(in1);
 nsta1=unique(station(in1));
 
 in2=find(depth>=1500 & ~isnan(c13));
 lon2=longitude(in2);
 lat2=latitude(in2);
 nsta2=unique(station(in2));

 in3=find(depth>=2000 & ~isnan(c13));
 lon3=longitude(in3);
 lat3=latitude(in3);
 nsta3=unique(station(in3));
syr=year(in1);
start_yr=min(syr);
yr=start_yr;
for i=1:max(syr)-min(syr)+1    
    ini=find(syr==yr); 
    count_yr(i)=length(ini);
    yr=yr+1;
end

% figure
% bar(count_yr);
% set(gca,'XLim',[0,45],'xtick',(0:5:45),'xticklabel',({'1980','1985','1990','1995',...
%     '2000','2005','2010','2015','2020','2025'...
%     '2025'}),'Fontsize',16,'Fontname','Times New Roman')
% set(gca,'ytick',(0:250:4000),'Fontsize',16,'Fontname','Times New Roman')
% xlabel('Year','Fontsize',18,'Fontname','Times New Roman');
% ylabel('Numbers per year','Fontsize',18,'Fontname','Times New Roman');
% grid on
% set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 5])
% % print(gcf,'-dtiff','-r300','Number of samples per year');

slat=sort(lat1);
start_lat=min(slat);
nlat=floor(start_lat);
for i=1:ceil(max(slat))-floor(min(slat))+1    
    ini=find(slat>=nlat & slat<nlat+1); 
    count_lat(i)=length(ini);
    nlat=nlat+1;
end

% figure
% bar(floor(start_lat):nlat-1,count_lat);
% set(gca,'XLim',[-75,80],'xtick',(-80:10:80),'Fontsize',16,'Fontname','Times New Roman')
% set(gca,'YLim',[0,450],'ytick',(0:50:500),'Fontsize',16,'Fontname','Times New Roman')
% xlabel('Latitude','Fontsize',18,'Fontname','Times New Roman');
% ylabel('Numbers per latitude','Fontsize',18,'Fontname','Times New Roman');
% grid on
% set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 5])
% % print(gcf,'-dtiff','-r300','Number of samples per latitude');

%%
figure
axes('position', [0.065 0.02 0.42 0.95])       
% base map
% m_proj('lambert','lons',[-70 25],'lat',[-80 10]);
% m_proj('Equidistant cylindrical','lons',[-60 30],'lat',[-80 10]);
m_proj('Equidistant cylindrical','lons',[-80 35],'lat',[-85 85]);
[cs,h]=m_etopo2('contourf',[-7000:50:0],'edgecolor','none');
m_coast('patch',[.8 .8 .8],'edgecolor','none');
m_grid('box','fancy','tickdir','in','linest','--','xaxislocation','bottom',...
    'Linewidth',1.5,'layer','top','Fontsize',15,'Fontname','Times New Roman');
caxis([-6000 000]);
c=colorbar('Fontsize',15,'Fontname','Times New Roman');
% set(get(c,'label'),'string','Depth (m)','Fontname','Times New Roman','fontsize',15)
set(get(c,'title'),'string','Depth (m)','Fontname','Times New Roman','fontsize',15)
load depthmap;
colormap(depthmap);
% colormap(m_colmap('blues')); 
hold on;
m_plot(lon1,lat1,'ko','MarkerSize',3,'MarkerEdgeColor','k','MarkerFaceColor','k')
% m_plot(lon2,lat2,'ro','MarkerSize',3,'MarkerEdgeColor','r','MarkerFaceColor','r') 
m_plot(lon3,lat3,'ro','MarkerSize',1.5,'MarkerEdgeColor','r','MarkerFaceColor','r') 
hold off
text(-0.98,1.35,'(a)','FontSize',18,'FontName','Times New Roman')

axes('position', [0.62 0.6 0.35 0.35])       
bar(count_yr);
set(gca,'XLim',[0,45],'xtick',(0:5:45),'xticklabel',({'1980','1985','1990','1995',...
    '2000','2005','2010','2015','2020','2025'...
    '2025'}),'Fontsize',15,'Fontname','Times New Roman')
set(gca,'YLim',[0,3500],'ytick',(0:500:3500),'Fontsize',15,'Fontname','Times New Roman')
xlabel('Year','Fontsize',16,'Fontname','Times New Roman');
ylabel('Numbers per year','Fontsize',16,'Fontname','Times New Roman');
grid on
text(2,3200,'(b)','FontSize',18,'FontName','Times New Roman')

axes('position', [0.62 0.1 0.35 0.35])       
bar(floor(start_lat):nlat-1,count_lat);
set(gca,'XLim',[-75,80],'xtick',(-80:20:80),'Fontsize',15,'Fontname','Times New Roman')
set(gca,'YLim',[0,450],'ytick',(0:50:500),'Fontsize',15,'Fontname','Times New Roman')
xlabel('Latitude','Fontsize',16,'Fontname','Times New Roman');
ylabel('Numbers per latitude','Fontsize',16,'Fontname','Times New Roman');
grid on
text(-69,420,'(c)','FontSize',18,'FontName','Times New Roman')

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 9 5.6])
print(gcf,'-dtiff','-r300','F1_stationsmap_count'); 
