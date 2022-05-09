function filename_beh = data_findBehFile(filename_neural)

split_filename = split(filename_neural,'-');
filename_beh = [split_filename{1} '-' split_filename{2} '-' split_filename{4}(1:8) '-beh'];

end