function dajo_datamap_post = data_sessionLocator(dajo_datamap, varargin)

dajo_penmap = table();
for ii = 1:size(dajo_datamap,1)
    dajo_penmap = [dajo_penmap; dajo_datamap.neurophysInfo{ii,1}];
end

for ii = 1:size(dajo_penmap,1)
dajo_penmap.monkey{ii} = dajo_penmap.dataFilename{ii}(1:3);
end

%% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));

% monkey, area, spacing, signal
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'monkey'}; monkey = varargin{varStrInd(iv)+1};
        case {'area'}; area = varargin{varStrInd(iv)+1}; 
        case {'spacing'}; spacing = varargin{varStrInd(iv)+1}; 
    end
end

if exist('monkey') == 1
    for ii = 1:length(monkey)
        monkeyTag = monkey{ii};
        monkey_flag(:,ii) = strcmp(dajo_penmap.monkey,monkeyTag);
    end
    monkey_flag = sum(monkey_flag,2);
else
    monkey_flag = ones(size(dajo_penmap,1),1);
end

if exist('area') == 1
    for ii = 1:length(area)
        areaTag = area{ii};
        area_flag(:,ii) = strcmp(dajo_penmap.area,areaTag);
    end
    area_flag = sum(area_flag,2);    
else
    area_flag = ones(size(dajo_penmap,1),1);
end

if exist('spacing') == 1
    for ii = 1:length(spacing)
        spacing_flag(:,ii) = dajo_penmap.spacing == spacing;
    end
    spacing_flag = sum(spacing_flag,2);    
else
    spacing_flag = ones(size(dajo_penmap,1),1);
end

dajo_datamap_post = ...
    dajo_penmap(monkey_flag == 1 & area_flag == 1 & spacing_flag == 1,:);


end