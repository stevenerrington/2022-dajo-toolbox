
clear all; clc

% Define working directories
dirs.nest = 'C:\Users\Steven\Desktop\';
dirs.toolbox = 'Projects\2022-dajo-toolbox';

% Load in datamap
dajo_datamap = load_datamap(dirs);

% Find sessions of interest
dajo_datamap_post = data_sessionLocator(dajo_datamap,...
    'area',{'DMFC','ACC'},...
    'monkey',{'dar','jou'},...
    'spacing',150,...
    'signal',{'LFP','SPK'}); % < In progress; 20220509

% Map between behavioural and neural data
neuralFilename = 'dar-cmand1DR-ACC-20210618'; % Example session
behFilename = data_findBehFile(neuralFilename);

behFilename = 'dar-cmand1DR-20210618-beh';
neuralFilename = data_findNeuralFile(behFilename, dajo_datamap);


%


% Behavioural extraction codes
[ttx, ttx_history, trialEventTimes] = beh_getTrials (stateFlags, Infos);
[stopSignalBeh, RTdist] = beh_getStoppingInfo(stateFlags,Infos,ttx);
[valueStopSignalBeh, valueRTdist] = beh_getValueStoppingInfo(stateFlags,Infos,ttx);

[ttm] = processTrialMatching(stopSignalBeh, ttx, trialEventTimes);
