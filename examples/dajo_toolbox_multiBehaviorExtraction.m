clear all; clc

%% Multi-session behavior
%  In this script, we can cycle through and extract pre-processed
%  behavioral information that can be used in future analyses. Such
%  information can include: trial indices, stop-signal behavior, timing of
%  events (from which response latencies can be calculated), amongst
%  others.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, we will setup our workspace, defining where our toolbox is 
% located, and where our data repository can be found.
dirs = data_setDir();

% We can then load in our master data map, which links sessions to
% penetrations and provides administrative details about the recording
dajo_datamap = load_datamap(dirs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Second, once we have our datamap, we can use our curation tool to find 
% and define sessions of interest, given a set of parameters.
% We start by defining these parameters; here, I am just looking for
% sessions with Monkey Da' ('dar') in which spike data ('SPK') was recorded
% from anterior cingulate cortex ('ACC')
areas = {'ACC'}; monkey = {'dar'}; signal = {'SPK'};

% We then use these criteria to curate our datamap, selecting only our
% sessions of interest
dajo_datamap_curated = data_sessionCurate...
    (dajo_datamap,...
    'area', areas, 'monkey', monkey, 'signal', signal);

% Once we have these penetrations, we will extract a list of unique  
% filenames (we chose unique filenames to get individual sessions, and  
% not repeat the import for dual penetration sessions).
dataFiles = unique(dajo_datamap_curated.sessionBeh);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Third, we can go ahead and start the loop to extract. Before doing this,
% we clear "behavior" variable to ensure it's clean to extract data in to.
clear behavior

% Looping through each of the individual data files
parfor dataFileIdx = 1:length(dataFiles)
    % We first report loop status:
    fprintf('Extracting: %s ... [%i of %i]  \n',dataFiles{dataFileIdx},dataFileIdx,length(dataFiles))
    
    % We then get the (behavior) filename of the record of interest
    behFilename = [dataFiles{dataFileIdx} '-beh'];
    % and load it into the workspace
    import_data = struct(); import_data = load_behFile(dirs,behFilename);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Once we have the behavior in matlab, we can then look to extract 
    % relevant task/session behavior. Currently, we focus on extracting
    % the session name, the trial indices (ttx), the timing of key events
    % (trialEventTimes), and stop-signal behavior (stopSignalBeh). More can
    % be added in this section, by generating a new variable and adding it
    % to the structure in line 72 (2022-05-11).
   
    sessionName = {behFilename}; % Get the session name
    [ttx, ~, trialEventTimes] =... % Index of trials and event timings
        beh_getTrials(import_data.events.stateFlags_,import_data.events.Infos_);
    [stopSignalBeh, ~] = beh_getStoppingInfo... % Stopping behavior
    (import_data.events.stateFlags_,import_data.events.Infos_,ttx);

    % After extracting the individual behavioral variable, we then collapse
    % it into one structure for the given session.
    behavior(dataFileIdx) = struct('sessionName',sessionName,'ttx',ttx,'trialEventTimes',trialEventTimes,...
        'stopSignalBeh',stopSignalBeh);

end

% Finally, we can save the output of this loop for future use. Here I am
% creating a new file in the dir.out folder, with the filename
% 2021-dajo-beh-YYYYMMDD. This file has the behavioral data and the curated
% datamap for reference.

tag = int2str(convertTo(datetime("today"),'YYYYMMDD'));
save(fullfile(dirs.out,['2021-dajo-beh-' tag '.mat']),'behavior','dajo_datamap_curated');
