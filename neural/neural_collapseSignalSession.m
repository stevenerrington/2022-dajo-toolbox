function signal_collapse = neural_collapseSignalSession(signal_average,varargin)

%% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'events'}; events = varargin{varStrInd(iv)+1};
        case {'conditions'}; conditions = varargin{varStrInd(iv)+1};
        case {'conditions_map'}; conditions_map = varargin{varStrInd(iv)+1};
    end
end

%%
nSessions   = length(signal_average);
nEvents     = length(events);
nConditions = length(conditions);

for event_i = 1:nEvents
    for condition_i = 1:nConditions
    condition_label = conditions{condition_i};

    signal_collapse.(events{event_i}).(condition_label) = [];

    for session_i = 1:nSessions
        signal_collapse.(events{event_i}).(conditions{condition_i}) = ...
            [signal_collapse.(events{event_i}).(conditions{condition_i});...
            signal_average{session_i}.session.(events{event_i}).(condition_label)];
    end
    
    end
end


end
