function [SDF] = spk_alignTrials(trialEventTimes, spkTimes, timeWin)

names = fieldnames( spkTimes );
subStr = 'DSP';
DSPstruct = rmfield( spkTimes, names( find( cellfun( @isempty, strfind( names , subStr ) ) ) ) );
DSPnames = fieldnames(DSPstruct);
endTime = round(max(max(trialEventTimes{:, :}))+10000); % Find last event stamp and add 10 secs

for DSPidx = 1:length(DSPnames)
    DSPlabel = DSPnames{DSPidx};
    
    SessionSDF = SpkConvolver (spkTimes.(DSPlabel), endTime, 'PSP');
    
    eventNames = fieldnames(trialEventTimes);
    eventNames = eventNames(1:length(eventNames)-3);
    
    for alignIdx = 1:length(eventNames)
        alignTimes = round(trialEventTimes.(eventNames{alignIdx})(:));
        
        alignedSDF_event = nan(length(alignTimes),range(timeWin)+1);
        
        for ii = 1:length(alignTimes)
            if isnan(alignTimes(ii)) | alignTimes(ii) == 0
                continue
            else
                alignedSDF_event(ii,:) = SessionSDF(alignTimes(ii)+timeWin(1):alignTimes(ii)+timeWin(end));
            end
        end
        
        alignedSDF{alignIdx} = alignedSDF_event;
        
    end
    
    for alignIdx = 1:length(eventNames)
        SDF.(DSPlabel).(eventNames{alignIdx}) = alignedSDF{alignIdx};
    end
    
    clear alignedSDF aligned_spkTimes
end

end

