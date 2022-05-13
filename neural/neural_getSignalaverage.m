function signal_average = neural_getSignalaverage(signal_data,varargin)

%% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'units'}; units = varargin{varStrInd(iv)+1};
        case {'events'}; events = varargin{varStrInd(iv)+1};
        case {'trials'}; trials = varargin{varStrInd(iv)+1};
    end
end



%%
nUnits      = length(units);
nEvents     = length(events);
nConditions = length(trials);

%%
% For each unit
for unit_i = 1:nUnits
    % For each event
    for event_i = 1:nEvents
        % For each condition
        for condition_i = 1:nConditions
            signal_conditions(condition_i,:) = nanmean(signal_data.(units{unit_i}).(events{event_i})(trials{condition_i},:));
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
