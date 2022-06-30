function [ttx, ttx_history, trialEventTimes] = beh_getTrials(stateFlags, Infos)
% Setup data
trialTypes = {'canceled','noncanceled','nostop','gowrong'};
targLocTypes = {'all','left','right'};
rewardAmountTypes = {'all','hi','lo'};

%% Get trial indices
clear tempttx rtTemp
tempttx.left = find(stateFlags.CurrTargIdx == 1);
tempttx.right = find(stateFlags.CurrTargIdx == 0);
tempttx.all = 1:max(stateFlags.TrialNumber);

tempttx.hi = find(stateFlags.IsHiRwrd == 1);
tempttx.lo = find(stateFlags.IsLoRwrd == 1);

tempttx.canceled = find(stateFlags.IsCancel == 1);
tempttx.noncanceled = find(stateFlags.IsNonCancelledNoBrk == 1 | stateFlags.IsNonCancelledBrk == 1);
tempttx.nostop = find(stateFlags.IsGoCorrect == 1);
tempttx.gowrong = find(stateFlags.IsGoErr == 1);

%% Find trials at each trial type, target location, and reward amount.
for trialTypeIdx = 1:length(trialTypes)
    trialType = trialTypes{trialTypeIdx};
    for targLocIdx = 1:length(targLocTypes)
        targLoc = targLocTypes{targLocIdx};
        for rewardAmountIdx = 1:length(rewardAmountTypes)
            rewardAmount = rewardAmountTypes{rewardAmountIdx};
            
            clear trialType_trialsLocation trialType_trialsReward
            trialType_trialsLocation = tempttx.(trialType)...
                (ismember(tempttx.(trialType),tempttx.(targLoc)));
            
            trialType_trialsReward = tempttx.(trialType)...
                (ismember(tempttx.(trialType),tempttx.(rewardAmount)));
            
            ttx.(trialType).(targLoc).(rewardAmount) =...
                trialType_trialsLocation(ismember...
                (trialType_trialsLocation,trialType_trialsReward));
            
        end
        
    end
end

%% Trial history
clear pre_nostop_ttx ttx_history

tempttx.nostopFiltered = tempttx.nostop;

pre_nostop_ttx = tempttx.nostopFiltered - 1;
pre_nostop_ttx = pre_nostop_ttx(pre_nostop_ttx > 0);

ttx_history.C_before_NS = pre_nostop_ttx(ismember(pre_nostop_ttx,tempttx.canceled));
ttx_history.NC_before_NS = pre_nostop_ttx(ismember(pre_nostop_ttx,tempttx.noncanceled));
ttx_history.NS_before_NS = pre_nostop_ttx(ismember(pre_nostop_ttx,tempttx.nostop));

ttx_history.NS_after_C = ttx_history.C_before_NS + 1;
ttx_history.NS_after_NC = ttx_history.NC_before_NS + 1;
ttx_history.NS_after_NS = ttx_history.NS_before_NS + 1;

%% trialEventTimes table
trialEventTimes = table();
trialEventTimes.fixSpotOn = Infos.FixSpotOn_;
trialEventTimes.fixation = Infos.AcquireFix_;
trialEventTimes.target = Infos.Target_;
trialEventTimes.stopSignal = Infos.StopSignal_;
trialEventTimes.saccade = Infos.Decide_;
trialEventTimes.tone = Infos.ToneDelayEnd_;
trialEventTimes.reward = Infos.RewardDelayEnd_;
trialEventTimes.timeout = Infos.TimeoutStart_;

nss_trl_idx = find(isnan(trialEventTimes.stopSignal));
% Stop-signal delay 
inh_SSD = unique(stateFlags.UseSsdVrCount);
ssdVRvalues = inh_SSD(~isnan(inh_SSD));
inh_SSD = round(ssdVRvalues*(1000/60));

% For each no stop-signal trial
for trlIdx = 1:length(nss_trl_idx)
    trl = nss_trl_idx(trlIdx);
    
    ssd_i = stateFlags.LastSsdIdx(trl)+1;
    
    
    if isnan(ssd_i)
        ssd_i = 3;
    end
    
    if ssd_i > length(inh_SSD)
        ssd_i = length(inh_SSD);
    end
    
    trialEventTimes.stopSignal_artifical(trl) = ...
        trialEventTimes.target(trl) + ... % Get the target time (as it's NaN for no target, we won't get a value).
        inh_SSD(ssd_i); % ... add the SSD (ms) from the previous stop trial
    
    
end


trialEventTimes.stopSignal_artifical(~isnan(trialEventTimes.stopSignal)) =...
    trialEventTimes.stopSignal(~isnan(trialEventTimes.stopSignal));




end
