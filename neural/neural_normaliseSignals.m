function [norm_signal_1, norm_signal_2] = neural_normaliseSignals(signal_1,signal_2,varargin)

%% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'method'}; method = varargin{varStrInd(iv)+1};
        case {'window'}; window = varargin{varStrInd(iv)+1};
    end
end

zero_offset = 1000;
n_obs = size(signal_1,1);

% If there is window to take the maximal window in, then do that
if exist('window') == 1; window = window+zero_offset;
    % otherwise, find the maximum across the whole window
else window = 1:length(signal_1);
end

switch method
    case {'max'}
        for obs_i = 1:n_obs
            max_fr = max([signal_1(obs_i,window), signal_2(obs_i,window)]);
            norm_signal_1(obs_i,:) = signal_1(obs_i,:)./max_fr;
            norm_signal_2(obs_i,:) = signal_2(obs_i,:)./max_fr;
        end
        
    case {'zscore'}
        for obs_i = 1:n_obs
            bl_mean = mean([signal_1(obs_i,window), signal_1(obs_i,window)]);
            bl_std  = std([signal_1(obs_i,window), signal_1(obs_i,window)]);
            
            norm_signal_1(obs_i,:) = (signal_1(obs_i,:)-bl_mean)./bl_std;
            norm_signal_2(obs_i,:) = (signal_2(obs_i,:)-bl_mean)./bl_std;
        end
end


  