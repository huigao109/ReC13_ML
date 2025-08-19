close all;clear;clc;

% load data
%  load('D:\carbon\North_Atlantic\Machine_Learning\Atlantic_c13_all_cruises.mat')
 % load('F:\North_Atlantic\Machine_Learning\Atlantic_c13_all_cruises.mat')
 load('Atlantic_cruises_with_c13.mat')

 [cruiseno,cruisename] = grp2idx(expocode);

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

% Quality flags filtering
salinity(salinityf~=2 & salinity~=6)=NaN;
aou(aouf~=2 & aouf~=6)=NaN;
nitrate(nitratef~=2 & nitratef~=6)=NaN;
silicate(silicatef~=2 & silicatef~=6)=NaN;
tco2(tco2f~=2 & tco2f~=6)=NaN;
talk(talkf~=2 & talk~=6)=NaN;
cfc12(cfc12f~=2 & cfc12f~=6)=NaN;
c13(c13f~=2 & c13f~=6)=NaN;

% training dataset
alldata.vars=[longitude, latitude, depth, temperature, salinity, aou, nitrate, silicate, tco2, xco2, c13];
% alldata.vars=[longitude, latitude, depth, temperature, salinity, nitrate, silicate, tco2, talk, xco2, c13];
a = double(alldata.vars);
a(a<-900) = nan;
alldata.vars = a;
ivalid = find(~isnan(sum(double(alldata.vars),2)));
data_valid = alldata.vars(ivalid,:);

features=data_valid(:,1:10);
targets=data_valid(:,11);

%% 
crno=cruiseno(ivalid); 
cruise_ids = unique(crno); 
    
X_train = features(crno ~= 25 & crno~=28, :); 
Y_train = targets(crno ~= 25 & crno~=28, :); 

%%
N_test = 1000;

u_T=0.002;
u_S=0.002;
u_N=0.4;
u_Si=0.4;
u_DIC=2;
u_AOU=2;
u_xCO2=0.2;

load('pred_eff_v5.mat')

%%
% Test temperature sensitivity
diff_c13_T = nan(size(X_train,1),N_test);
for itest = 1:N_test
    T_all_i = X_train;
    ei = normrnd(0,u_T,size(X_train,1),1);
    T_all_i(:,4) = X_train(:,4) + ei;
    [X_train, mu, sigma] = zscore(X_train);
    y_test_1 = trainedModel.predictFcn(X_train);
    diff_c13_T(:,itest) = y_test_1 - validationPredictions;
end
diff_c13_T_avg = nanstd(diff_c13_T,0,2);
figure
hist(diff_c13_T_avg,100);

% Test salnity sensitivity
diff_c13_S = nan(size(X_train,1),N_test);
for itest = 1:N_test
    T_all_i = X_train;
    ei = normrnd(0,u_S,size(X_train,1),1);
    T_all_i(:,5) = X_train(:,5) + ei;
    [X_train, mu, sigma] = zscore(X_train);
    y_test_1 = trainedModel.predictFcn(X_train);
    diff_c13_S(:,itest) = y_test_1 - validationPredictions;
end
diff_c13_S_avg = nanstd(diff_c13_S,0,2);
figure
hist(diff_c13_S_avg,100);

% Test AOU sensitivity
diff_c13_AOU = nan(size(X_train,1),N_test);
for itest = 1:N_test
    T_all_i = X_train;
    ei = normrnd(0,u_AOU,size(X_train,1),1);
    T_all_i(:,6) = X_train(:,6) + ei;
    [X_train, mu, sigma] = zscore(X_train);
    y_test_1 = trainedModel.predictFcn(X_train);
    diff_c13_AOU(:,itest) = y_test_1 - validationPredictions;
end
diff_c13_AOU_avg = nanstd(diff_c13_AOU,0,2);
figure
hist(diff_c13_AOU_avg,100);

% Test nitrate sensitivity
diff_c13_N = nan(size(X_train,1),N_test);
for itest = 1:N_test
    T_all_i = X_train;
    ei = normrnd(0,u_N,size(X_train,1),1);
    T_all_i(:,7) = X_train(:,7) + ei;
    [X_train, mu, sigma] = zscore(X_train);
    y_test_1 = trainedModel.predictFcn(X_train);
    diff_c13_N(:,itest) = y_test_1 - validationPredictions;
end
diff_c13_N_avg = nanstd(diff_c13_N,0,2);
figure
hist(diff_c13_N_avg,100);

% Test silicate sensitivity
diff_c13_Si = nan(size(X_train,1),N_test);
for itest = 1:N_test
    T_all_i = X_train;
    ei = normrnd(0,u_Si,size(X_train,1),1);
    T_all_i(:,8) = X_train(:,8) + ei;
    [X_train, mu, sigma] = zscore(X_train);
    y_test_1 = trainedModel.predictFcn(X_train);
    diff_c13_Si(:,itest) = y_test_1 - validationPredictions;
end
diff_c13_Si_avg = nanstd(diff_c13_Si,0,2);
figure
hist(diff_c13_Si_avg,100);

% Test DIC sensitivity
diff_c13_DIC = nan(size(X_train,1),N_test);
for itest = 1:N_test
    T_all_i = X_train;
    ei = normrnd(0,u_DIC,size(X_train,1),1);
    T_all_i(:,9) = X_train(:,9) + ei;
    [X_train, mu, sigma] = zscore(X_train);
    y_test_1 = trainedModel.predictFcn(X_train);
    diff_c13_DIC(:,itest) = y_test_1 - validationPredictions;
end
diff_c13_DIC_avg = nanstd(diff_c13_DIC,0,2);
figure
hist(diff_c13_DIC_avg,100);

% Test xCO2 sensitivity
diff_c13_xCO2 = nan(size(X_train,1),N_test);
for itest = 1:N_test
    T_all_i = X_train;
    ei = normrnd(0,u_xCO2,size(X_train,1),1);
    T_all_i(:,10) = X_train(:,10) + ei;
    [X_train, mu, sigma] = zscore(X_train);
    y_test_1 = trainedModel.predictFcn(X_train);
    diff_c13_xCO2(:,itest) = y_test_1 - validationPredictions;
end
diff_c13_xCO2_avg = nanstd(diff_c13_xCO2,0,2);
figure
hist(diff_c13_xCO2_avg,100);

diff_c13_all = sqrt(diff_c13_T_avg.^2 + diff_c13_S_avg.^2 + diff_c13_N_avg.^2 ...
    + diff_c13_Si_avg.^2 + diff_c13_DIC_avg.^2 + diff_c13_AOU_avg.^2 + diff_c13_xCO2_avg.^2);

save('uncertainty_fin.mat','diff_c13_all', 'diff_c13_T_avg', 'diff_c13_S_avg', 'diff_c13_N_avg', ...
    'diff_c13_Si_avg', 'diff_c13_DIC_avg', 'diff_c13_AOU_avg', 'diff_c13_xCO2_avg');

%%
mean(diff_c13_all)
mean(diff_c13_T_avg)
mean(diff_c13_S_avg)
mean(diff_c13_N_avg)
mean(diff_c13_Si_avg)
mean(diff_c13_DIC_avg)
mean(diff_c13_AOU_avg)
mean(diff_c13_xCO2_avg)


