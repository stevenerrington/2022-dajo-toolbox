
clear all; clc

% Define working directories
dirs.nest = 'C:\Users\Steven\Desktop\';
dirs.toolbox = 'Projects\2022-dajo-toolbox';

% Load in datamap
dajo_datamap = load_dajo_datamap(dirs);

% Find sessions of interest
monkey = 'jou'; area = 'ACC'; spk = 1; lfp = 1; spacing = '150';

dajo_datamap_post = data_sessionLocator(dajo_datamap,...
    'area',{'DMFC','ACC'},...
    'monkey',{'dar','jou'},...
    'spacing',150,...
    'signal',{'LFP','SPK'}); % < In progress; 20220509



behFiles = data_findBehFile(dajo_datamap, dajo_datamap_post.dataFilename);  % < In progress; 20220509



% Behavioural extraction codes
[ttx, ttx_history, trialEventTimes] = beh_getTrials (stateFlags, Infos);
[stopSignalBeh, RTdist] = beh_getStoppingInfo(stateFlags,Infos,ttx);
[valueStopSignalBeh, valueRTdist] = beh_getValueStoppingInfo(stateFlags,Infos,ttx);

[ttm] = processTrialMatching(stopSignalBeh, ttx, trialEventTimes);
tdtEyes = alignEyes(trialEventTimes,TrialEyes, [-1000 2000]); % <- This needs checking!
tdtLFP_aligned = alignLFP(trialEventTimes,tdtLFP, timeWin);
tdtSpk_aligned = alignSDF(trialEventTimes, Infos, tdtSpk, timeWin);