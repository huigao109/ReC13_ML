close all;clear;clc;

load('GLODAPv2.2023_Atlantic_Ocean.mat')

 load('monthlyinsituco2mlo.mat')
 
xco2 = NaN(size(G2year)); 

for i = 1:length(G2year)
    matched_row = monthlyinsituco2mlo(monthlyinsituco2mlo.Yr == G2year(i) & monthlyinsituco2mlo.Mn == G2month(i), :);
    if ~isempty(matched_row)
        xco2(i) = matched_row.CO2; 
    end
end

input_vars=[G2longitude, G2latitude, G2depth, G2temperature, G2salinity, ...
    G2aou, G2nitrate, G2silicate, G2tco2, xco2];

ivalid = find(~isnan(sum(input_vars,2)));
data_valid = input_vars(ivalid,:);

load('pred_eff_fin.mat')
input_vars_nor = (data_valid - mu) ./ sigma;

reconstructed_c13 = NaN(size(input_vars,1),1);
reconstructed_c13(ivalid) = trainedModel.predictFcn(input_vars_nor);
in=intersect(ivalid, find((G2salinityf==2 | G2salinityf==6) & (G2nitritef==2 | G2nitritef==6) & (G2silicatef==2 | G2silicatef==6)...
    & (G2tco2f==2 | G2tco2f==6) & (G2aouf==2 | G2aouf==6)));

c13f=G2c13(ivalid);
in2=find(c13f==2 | c13f==6);

reconstructed_c13f = 3 * ones(size(reconstructed_c13));
reconstructed_c13f(in) = 2;
nan_indices = isnan(reconstructed_c13);
reconstructed_c13f(nan_indices) = 9;

save('reconstruceted_c13_GLODAPv2.2023.mat','reconstructed_c13','reconstructed_c13f');
