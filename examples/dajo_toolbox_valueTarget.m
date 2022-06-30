clear all; clc
getColors
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
areas = {'ACC'}; monkey = {'dar','jou'}; signal = {'SPK'};

% We then use these criteria to curate our datamap, selecting only our
% sessions of interest
dajo_datamap_curated = data_sessionCurate...
    (dajo_datamap,...
    'area', areas, 'monkey', monkey, 'signal', signal);

% Once we have these penetrations, we will extract a list of unique
% filenames (we chose unique filenames to get individual sessions, and
% not repeat the import for dual penetration sessions).
dataFiles_beh = unique(dajo_datamap_curated.sessionBeh);
dataFiles_neural = unique(dajo_datamap_curated.dataFilename);

%% Behavior
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Third, we can go ahead and start the loop to extract. Before doing this,
% we clear "behavior" variable to ensure it's clean to extract data in to.
clear behavior

% Looping through each of the individual data files
parfor beh_i = 1:length(dataFiles_beh)
    % We first report loop status:
    fprintf('Extracting: %s ... [%i of %i]  \n',dataFiles_beh{beh_i},beh_i,length(dataFiles_beh))
    
    % We then get the (behavior) filename of the record of interest
    behFilename = [dataFiles_beh{beh_i} '-beh'];
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
    behavior(beh_i) = struct('sessionName',sessionName,'ttx',ttx,'trialEventTimes',trialEventTimes,...
        'stopSignalBeh',stopSignalBeh);
    
end


%% Neural
nWorkers = 5;

parfor (neural_i = 1:length(dataFiles_neural),nWorkers)
    % We first report loop status:
    fprintf('Extracting: %s ... [%i of %i]  \n',dataFiles_neural{neural_i},neural_i,length(dataFiles_neural))
    
    % We then get the (neural) filename of the record of interest
    neuralFilename = dataFiles_neural{neural_i};
    
    %... and find the corresponding behavior file index
    behFilename = data_findBehFile(neuralFilename);
    behaviorIdx = find(strcmp(dataFiles_beh,behFilename(1:end-4)));
    
    % Load in data-file
    import_data = struct(); import_data = load_spkFile(dirs,neuralFilename);
    
    % Convolve spike times to get continous trace
    spk_data = [];
    spk_data = spk_alignTrials(behavior(behaviorIdx).trialEventTimes(:,[3]),...
        import_data.time, [-1000 2000]);
    
    trial_nostop_hi = [];  trial_nostop_lo = [];
    trial_nostop_hi = behavior(behaviorIdx).ttx.nostop.all.hi;
    trial_nostop_lo = behavior(behaviorIdx).ttx.nostop.all.lo;
    
    signal_average{neural_i} = neural_getSignalAverage(spk_data,...
        'units',fieldnames(spk_data),...
        'events',{'target'},...
        'trials',{trial_nostop_hi,trial_nostop_lo},...
        'conditions',{'hi','lo'});
end


signal_collapse = neural_collapseSignalSession(signal_average,...
    'events',{'target'},...
    'conditions',{'hi','lo'},...
    'conditions_map',[1 2]);


 [norm_signal_1, norm_signal_2] = neural_normaliseSignals...
     (signal_collapse.target.hi,...
     signal_collapse.target.lo,...
     'method','max');


 %% Clustering
 % Processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Provide a cell array of SDF's split by conditions
inputSDF = {signal_collapse.target.hi,... % Target aligned, high reward
    signal_collapse.target.lo};           % Target aligned, low reward

% Provide the times at which the SDFs run to and from.
sdfTimes = {[-1000:2000], [-1000:2000]};

% These are the epochs of interest in which to cluster dynamics on.
epochTimes = {[-100:250],[-100:250]};
% Then relate these epochs to a particular cell index of the inputSDF
% array.
epochMap = [1,2];
% Run the clustering tool
[sortIDs,idxDist, raw, respSumStruct, rawLink,myK] =...
    consensusCluster(inputSDF,sdfTimes,...
    '-e',epochTimes,...
    '-ei',epochMap);

% Normalise the SDFs
% normResp = scaleResp(inputSDF,sdfTimes,'z','-bl',[-100:0]);
normResp = {norm_signal_1, norm_signal_2};

% Post-processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nClusters_manual = 4; 
clusterNeurons = [];
for i = 1:nClusters_manual
    clusterNeurons{i} = find(sortIDs(:,nClusters_manual) == i );
end

% Plot cluster dendrogram, and average SDF %%%%%%%%%%
figure('Renderer', 'painters', 'Position', [100 100 500 400]);

subplot(1,5,5)
[h,~,outPerm] = dendrogram(rawLink,0,'Orientation','right');
set(gca,'YDir','Reverse');
klDendroClustChange(h,rawLink,sortIDs(:,nClusters_manual))
set(gca,'YTick',[]); xlabel('Similarity')

subplot(1,5,[1:4]);
for ir = 1:size(raw,1)
    for ic = (ir+1):size(raw,2)
        raw(ic,ir) = raw(ir,ic);
    end
end
imagesc(raw(outPerm,outPerm));
colormap(gray);
xlabel('Unit Number'); set(gca,'YAxisLocation','Left');
xticks([0:100:end]); yticks([0:100:end])

 figure('Renderer', 'painters', 'Position', [100 100 1200 250]);hold on

for i = 1:nClusters_manual
    subplot(1,nClusters_manual,i); hold on
    plot(sdfTimes{1},nanmean(normResp{1}(clusterNeurons{i},:),1), 'color', 'r');
    plot(sdfTimes{2},nanmean(normResp{2}(clusterNeurons{i},:),1), 'color', 'b');
    vline(0, 'k--'); xlim([-200 600])
    
    title(['Cluster ' int2str(i) ' - n: ' int2str(length(clusterNeurons{i}))])
    
end



%% PCA Analysis: Stop-Signal
% Set data parameters & windows
ephysWin = [-1000 2000]; winZero = abs(ephysWin(1));
plotWin = [-250:500]; 
analyseTime = [-100:200];
getColors

% Set PCA parameters
samplingRate = 1/1000; % inherent to the data. Do not change
numPCs = 8; % pick a number that will capture most of the variance
timeStep = 10; % smaller values will yield high resolution at the expense of computation time, default will sample at 20ms
withinConditionsOnly = false; % if true, will only analyze tanlging for times within the same condition

clear PCA_mainInput PCA_mainOutput
% Setup data for PCA analysis
PCA_mainInput(1).A = signal_collapse.target.hi';
PCA_mainInput(1).times = plotWin';
PCA_mainInput(1).analyzeTimes = analyseTime';
PCA_mainInput(1).condition = 'High Reward';
PCA_mainInput(1).color = [colors.hiRew 1];

PCA_mainInput(2).A = signal_collapse.target.lo';
PCA_mainInput(2).times = plotWin';
PCA_mainInput(2).analyzeTimes = analyseTime';
PCA_mainInput(2).condition = 'High Reward';
PCA_mainInput(2).color = [colors.loRew 1];


% Run PCA analysis
[~, PCA_mainOutput] = tangleAnalysis(PCA_mainInput, samplingRate,'numPCs',numPCs,'softenNorm',5 ,'timeStep',timeStep,'withinConditionsOnly',withinConditionsOnly); % soft normalize neural data
pca_figure(PCA_mainInput,PCA_mainOutput)



