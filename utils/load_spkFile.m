function spikes = load_spkFile(dirs,spkFilename)
fullFile = fullfile(dirs.data,[spkFilename '-spk.mat']);
load(fullFile);

end
