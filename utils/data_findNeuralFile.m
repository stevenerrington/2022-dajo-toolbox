function filename_neural = data_findNeuralFile(filename_beh, dajo_datamap)

datamap_idx = find(strcmp(dajo_datamap.session,filename_beh(1:end-4)));
filename_neural = dajo_datamap.neurophysInfo{datamap_idx}.dataFilename;
end