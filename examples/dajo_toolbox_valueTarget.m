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
% dataFiles = dataFiles(1:10);

%% Behavior
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


%% Neural
parfor dataFileIdx = 1:length(dataFiles)
    % We first report loop status:
    fprintf('Extracting: %s ... [%i of %i]  \n',dataFiles{dataFileIdx},dataFileIdx,length(dataFiles))
    
    % We then get the (behavior) filename of the record of interest
    behFilename = [dataFiles{dataFileIdx} '-beh'];
    % and load it into the workspace
    neuralFilename = data_findNeuralFile(behFilename, dajo_datamap);
    
    % For each neural recording in the given session
    neural_fileIdx = 1; % <-------- ATTEND FOR MULTIPLE PENS IN ONE SESSION
    % Load in data-file
    import_data = struct(); import_data = load_spkFile(dirs,neuralFilename{neural_fileIdx});
    % Convolve spike times to get continous trace
    spk_data = [];
    spk_data = spk_alignTrials(behavior(dataFileIdx).trialEventTimes(:,[3,6]),...
        import_data.time, [-1000 2000]);
    
    trial_nostop_hi = [];  trial_nostop_lo = [];
    trial_nostop_hi = behavior(dataFileIdx).ttx.nostop.all.hi;
    trial_nostop_lo = behavior(dataFileIdx).ttx.nostop.all.lo;
    
    signal_average{dataFileIdx} = neural_getSignalaverage(spk_data,...
        'units',fieldnames(spk_data),...
        'events',{'target','tone'},...
        'trials',{trial_nostop_hi,trial_nostop_lo});
end


signal_collapse = neural_collapseSignalSession(signal_average,...
    'events',{'target','tone'},...
    'conditions',{'hi','lo'},...
    'conditions_map',[1 2]);


 [norm_signal_1, norm_signal_2] = neural_normaliseSignals...
     (signal_collapse.target.hi,...
     signal_collapse.target.lo,...
     'method','max');

