function lfp = load_lfpFile(dirs,lfpFilename)
fullFile = fullfile(dirs.nest, dirs.data,[lfpFilename '-lfp.mat']);
load(fullFile);

end
