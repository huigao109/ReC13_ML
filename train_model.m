close all;clear;clc;

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

% % not considered cruises
% c13(expocode=="06MT20110405")=NaN;
% c13(expocode=="18DL20150710")=NaN;
% c13(expocode=="29GD20120910")=NaN;
% c13(expocode=="33LG20060321")=NaN;
% c13(expocode=="33LG20090916")=NaN;
% c13(expocode=="35A320031214")=NaN;
% c13(expocode=="49NZ20031106")=NaN;
% c13(expocode=="740H20180228")=NaN;
% c13(expocode=="74JC20181103")=NaN;

% Exclude certain cruises
excludedCruises = ["06MT20110405","18DL20150710","29GD20120910","33LG20060321",...
                   "33LG20090916","35A320031214","49NZ20031106","740H20180228","74JC20181103"];
for ex = excludedCruises
    c13(expocode == ex) = NaN;
end

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
    
X_test = features(crno == 25 | crno == 28, :); 
Y_test = targets(crno == 25 | crno == 28, :); 
X_train = features(crno ~= 25 & crno~=28, :); 
Y_train = targets(crno ~= 25 & crno~=28, :); 

% Standardize
[X_train, mu, sigma] = zscore(X_train);
X_test = (X_test - mu) ./ sigma;

% [trainedModel, validationRMSE, validationPredictions] = trainGPR19v2(X_train,Y_train);
% pre_test = trainedModel.predictFcn(X_test);
% lm_i = fitlm(pre_test,Y_test);
% save('pred_eff_v2.mat','trainedModel','validationRMSE','Y_train','validationPredictions','Y_test','pre_test','lm_i', 'mu', 'sigma','-mat');

% Train GPR model
[trainedModel, validationRMSE, validationPredictions] = trainGPR19v3(X_train, Y_train);

% Predictions
% Mean prediction only
pre_test = trainedModel.predictFcn(X_test);  % pre_test → mean prediction   

% Prediction with uncertainty
[mu_test, sigma_test, ci_test] = trainedModel.predictFcnWithUncertainty(X_test);   % mu_test, sigma_test, ci_test → mean, std, and 95% CI from GPR

% Fit linear model for evaluation
lm_i = fitlm(pre_test, Y_test);


% For training set
[Y_pred_train, Y_std_train] = predict(trainedModel.RegressionGP, X_train);

% For test set
[Y_pred_test, Y_std_test] = predict(trainedModel.RegressionGP, X_test);


% % Save results
% save('pred_eff_fin.mat', ...
%     'trainedModel', 'validationRMSE', 'Y_train', 'Y_pred_train', 'Y_std_train','validationPredictions', ...
%     'Y_test', 'pre_test','Y_pred_test', 'Y_std_test', 'mu_test', 'sigma_test', 'ci_test', ...
%     'lm_i', 'mu', 'sigma', '-v7.3');

save('pred_eff.mat', ...
    'trainedModel', 'validationRMSE', 'validationPredictions', ...
    'lm_i', 'mu', 'sigma', '-v7.3');
