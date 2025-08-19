function [trainedModel, validationRMSE, validationPredictions] = trainGPR19v3(trainingData, responseData)
% [trainedModel, validationRMSE, validationPredictions] = trainGPR19v2(trainingData, responseData)
% Trains a Gaussian Process Regression (GPR) model and provides functions
% to predict both the mean and the uncertainty (standard deviation & confidence intervals).
%
% Usage:
%   [model, rmse] = trainGPR19v3(Xtrain, Ytrain);
%   ymean = model.predictFcn(Xtest);                       % Mean prediction only
%   [mu, sigma, ci] = model.predictFcnWithUncertainty(Xtest); % Mean, std, and CI
% 
% mu = mean prediction
% sigma = predictive standard deviation (uncertainty)
% ci = 95% confidence interval for each prediction

%
% Inputs:
%   trainingData  - Matrix of predictors for training
%   responseData  - Vector of response values
%
% Outputs:
%   trainedModel          - Struct containing the trained model and prediction functions
%   validationRMSE        - RMSE from 10-fold cross-validation
%   validationPredictions - Predictions from cross-validation

    % Convert predictors to table format
    inputTable = array2table(trainingData, ...
        'VariableNames', {'column_1','column_2','column_3','column_4','column_5',...
                          'column_6','column_7','column_8','column_9','column_10'});

    predictorNames = {'column_1', 'column_2', 'column_3', 'column_4', 'column_5', ...
                      'column_6', 'column_7', 'column_8', 'column_9', 'column_10'};
    predictors = inputTable(:, predictorNames);
    response = responseData;

    % % Train Gaussian Process Regression model
    % regressionGP = fitrgp(...
    %     predictors, ...
    %     response, ...
    %     'BasisFunction', 'constant', ...
    %     'KernelFunction', 'matern52', ...
    %     'Standardize', true);
    
    regressionGP = fitrgp(...
    predictors, ...
    response, ...
    'BasisFunction', 'constant', ...
    'KernelFunction', 'matern52', ...
    'Standardize', true, ...
    'PredictMethod', 'exact');   % force exact predictions

    % Prediction function (mean only)
    predictorExtractionFcn = @(x) array2table(x, 'VariableNames', predictorNames);
    gpPredictFcn = @(x) predict(regressionGP, x);
    trainedModel.predictFcn = @(x) gpPredictFcn(predictorExtractionFcn(x));

    % Prediction function with uncertainty
    gpPredictWithUncertaintyFcn = @(x) predict(regressionGP, predictorExtractionFcn(x));
    trainedModel.predictFcnWithUncertainty = @(x) gpPredictWithUncertaintyFcn(x);

    % Store model and usage info
    trainedModel.RegressionGP = regressionGP;
    trainedModel.About = 'Gaussian Process Regression model with uncertainty estimation support.';
    trainedModel.HowToPredict = sprintf([ ...
        'For mean prediction only:\n  yfit = model.predictFcn(Xnew)\n' ...
        'For mean + uncertainty:\n  [mu, sigma, ci] = model.predictFcnWithUncertainty(Xnew)\n']);

    % Perform 10-fold cross-validation
    partitionedModel = crossval(trainedModel.RegressionGP, 'KFold', 10);
    validationPredictions = kfoldPredict(partitionedModel);
    validationRMSE = sqrt(kfoldLoss(partitionedModel, 'LossFun', 'mse'));
end
