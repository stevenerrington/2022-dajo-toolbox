function dajo_datamap_post = data_sessionLocator(dajo_datamap, varargin)

dajo_penmap = table();
for ii = 1:size(dajo_datamap,1)
    dajo_penmap = [dajo_penmap; dajo_datamap.neurophysInfo{ii,1}];
end

%% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'monkey'}; monkey = varargin{varStrInd(iv)+1};
        case {'area'}; area = varargin{varStrInd(iv)+1}; 
        case {'spacing'}; spacing = varargin{varStrInd(iv)+1}; 
        case {'signal'}; signal = varargin{varStrInd(iv)+1}; 
    end
end



end