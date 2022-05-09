function spikes = load_spkFile(dirs,spkFilename)
fullFile = fullfile(dirs.nest, dirs.data,[spkFilename '-spk.mat']);
load(fullFile);

end
