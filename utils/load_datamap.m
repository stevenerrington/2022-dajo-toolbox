function dajo_datamap = load_datamap(input_dir)
    file_location = fullfile(input_dir,'2021-dajo-datamap.mat');
    load(file_location);
    clear file_location
end
