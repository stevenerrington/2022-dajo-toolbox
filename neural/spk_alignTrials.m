function [sdf, spk, raster] = spk_alignTrials(trialEventTimes, spkTimes, timeWin)

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
    
    alignedSDF = {}; alignedSPK = {}; alignedRaster = {};
    
    
    for alignIdx = 1:length(eventNames)
        alignTimes = round(trialEventTimes.(eventNames{alignIdx})(:));
        
        alignedSDF_event = nan(length(alignTimes),range(timeWin)+1);
        raster_temp = zeros(length(alignTimes),range(timeWin)+1);
        
        spk_aligntemp = {};
        for trl_i = 1:length(alignTimes)
            if isnan(alignTimes(trl_i)) | alignTimes(trl_i) == 0
                spk_aligntemp{trl_i,1} = [];
            else
                alignedSDF_event(trl_i,:) = SessionSDF(alignTimes(trl_i)+timeWin(1):alignTimes(trl_i)+timeWin(end));
                spk_aligntemp{trl_i,1} = intersect(spkTimes.(DSPlabel),alignTimes(trl_i)+[timeWin(1):timeWin(2)])-...
                    alignTimes(trl_i);
                
                trl_spkTimes = spk_aligntemp{trl_i,1}+abs(min(timeWin(1)))+1;
                raster_temp(trl_i,trl_spkTimes) = 1;
            end
        end
        
        alignedSDF{alignIdx} = alignedSDF_event;
        alignedSPK{alignIdx} = spk_aligntemp;
        alignedRaster{alignIdx} = raster_temp;
        
    end
    
    for alignIdx = 1:length(eventNames)
        sdf.(DSPlabel).(eventNames{alignIdx}) = alignedSDF{alignIdx};
        spk.(DSPlabel).(eventNames{alignIdx}) = alignedSPK{alignIdx};
        raster.(DSPlabel).(eventNames{alignIdx}) = alignedRaster{alignIdx};
    end
    
    clear alignedSDF aligned_spkTimes
end

end

