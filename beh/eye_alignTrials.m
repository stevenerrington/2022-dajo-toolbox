function tdtEyes = eye_alignTrials(trialEventTimes, TrialEyes, timeWin)

Fs = TrialEyes.FsHz;

eventNames = fieldnames(trialEventTimes);
eventNames = eventNames(1:length(eventNames)-3);


for alignIdx = 1:length(eventNames)
    clear alignTimes alignedEyeX_event alignedEyeY_event alignedEyePD_event
    eventName = eventNames{alignIdx};
    alignTimes = trialEventTimes.(eventName);  
    
    alignedEyeX_event = nan(length(alignTimes),range(timeWin)+1);
    alignedEyeY_event = nan(length(alignTimes),range(timeWin)+1);
    alignedEyePD_event = nan(length(alignTimes),range(timeWin)+1);
    
    for ii = 1:length(alignTimes)
        if isnan(alignTimes(ii))
            continue
        else
            clear sampleWindow
            idx_1 = util_adjustTDTfs(alignTimes(ii)- TrialEyes.StartTime, Fs) + timeWin(1) *2;
            idx_2 = util_adjustTDTfs(alignTimes(ii)- TrialEyes.StartTime, Fs) + timeWin(2)*2;
            sampleWindow = idx_1:2:idx_2;
            
            alignedEyeX_event(ii,:) = TrialEyes.EyeX(sampleWindow);
            alignedEyeY_event(ii,:) = TrialEyes.EyeY(sampleWindow);
            alignedEyePD_event(ii,:) = TrialEyes.EyePupil(sampleWindow);
        end
    end
    
    tdtEyes.X.(eventName) = alignedEyeX_event;
    tdtEyes.Y.(eventName) = alignedEyeY_event;
    tdtEyes.Pupil.(eventName) = alignedEyePD_event;
end


end
