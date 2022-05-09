function data = load_behFile(dirs,behFilename)
fullFile = fullfile(dirs.nest, dirs.data,[behFilename '.mat']);
data = load(fullFile);

end
