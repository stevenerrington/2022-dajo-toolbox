function lfp = load_lfpFile(dirs,lfpFilename)
fullFile = fullfile(dirs.data,[lfpFilename '-lfp.mat']);
load(fullFile);

end
