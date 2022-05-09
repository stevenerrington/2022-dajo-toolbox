function dajo_datamap = load_datamap(dirs)
    file_location = fullfile(dirs.nest, dirs.toolbox, 'data','2021-dajo-datamap.mat');
    load(file_location);
    clear file_location
end
