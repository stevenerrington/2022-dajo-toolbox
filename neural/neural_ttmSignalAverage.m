function signal_average = neural_ttmSignalAverage(signal_data,ttm,varargin)

%% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'units'}; units = varargin{varStrInd(iv)+1};
        case {'events'}; events = varargin{varStrInd(iv)+1};
        case {'ssd'}; ssd = varargin{varStrInd(iv)+1};
        case {'weighting'}; weighting = varargin{varStrInd(iv)+1};
    end
end

%% Define n's for loop
nUnits      = length(units);
nEvents     = length(events);
conditionLabels = fieldnames(ttm);
nConditions = length(conditionLabels);
nSSD = length(ssd);

%%
% For each unit
for unit_i = 1:nUnits
    % For each event
    for event_i = 1:nEvents
        
        % For each condition
        for condition_i = 1:nConditions
            
            % For each SSD of interest
            for ssd_i = 1:nSSD
                % Find the SSD index that we are referring to
                ssd_idx = ssd(ssd_i);
                % and find the relevant trials at the given SSD and
                % condition.
                ssd_trials = []; ssd_trials = ttm.(conditionLabels{condition_i}){ssd_i};
                % ... and make a note of the number of trials for this
                % combination
                nTr(ssd_i) = length(ssd_trials);
                
                % We can then get the signal averaged across these trials.                                
                signal_conditions_ssd(ssd_i,:) = ...
                    nanmean(signal_data.(units{unit_i}).(events{event_i})(ssd_trials,:));
            end
            
            % Average post-latency matched signals
            if strcmp(weighting,'on')
                % Get the proportion of trials for each SSD inputted
               nTr_weighting = nTr/sum(nTr);
               % For each SSD trial averaged activity
               for ssd_i = 1:length(nTr_weighting)
                   % Weight the average activity by the proportion of
                   % trials
                   signal_conditions_ssd(ssd_i,:) = signal_conditions_ssd(ssd_i,:).*nTr_weighting(ssd_i);
               end
               % ... and then sum them together to get the weighted
               % average.
                signal_conditions(condition_i,:) = nansum(signal_conditions_ssd);
               
            else
                % Otherwise, just average across all SSD's without
                % weighting.
                signal_conditions(condition_i,:) = nanmean(signal_conditions_ssd);
            end
        end
        
        signal_average.individual.(events{event_i})(unit_i,:) =...
            table(units(unit_i),{signal_conditions},'VariableName',{'unit','signal_average'});
    end
end

%%
for unit_i = 1:nUnits
    % For each event
    for event_i = 1:nEvents
        % For each condition
        for condition_i = 1:nConditions
            condition_label = ['condition_' int2str(condition_i)];
            
            signal_average.session.(events{event_i}).(condition_label)(unit_i,:)=...
                signal_average.individual.(events{event_i}).signal_average{unit_i}(condition_i,:);
        end
    end
end


end
