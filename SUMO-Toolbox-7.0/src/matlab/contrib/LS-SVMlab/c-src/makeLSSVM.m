function [] = makeLSSVM(target)

oldDir = pwd;
dir = mfilename('fullpath');
dir = dir(1:end-9);
cd(dir);


SRC_TRAIN = 'lssvm.c cga.c kernels.c lssvm_classificator.c lssvm_fctest.c lssvm_timeserie.c lssvm_NARX.c kernel_cache.c';
SRC_SIM = 'simclssvm.c cga.c kernels.c lssvm_classificator.c lssvm_fctest.c lssvm_timeserie.c lssvm_NARX.c kernel_cache.c';
SRC_FILE = 'lssvmFILE.c cga.c kernels.c lssvm_classificator.c lssvm_fctest.c lssvm_timeserie.c lssvm_NARX.c kernel_cache.c';
SRC_SIMFILE = 'simFILE.c lssvm_classificator.c lssvm_fctest.c lssvm_timeserie.c lssvm_NARX.c kernel_cache.c kernels.c cga.c';

if ~exist('target')
	target = 'all';
end

if strcmp(target, 'lssvm') || strcmp(target, 'all')
	copyfile('memSpecMEX.h', 'memSpec.h');
	buildList(SRC_TRAIN);
end

if strcmp(target, 'simclssvm') || strcmp(target, 'all')
	copyfile('memSpecMEX.h', 'memSpec.h');
	buildList(SRC_SIM);
end

cd(oldDir);


function [] = buildList(list)

	% build all files
	files = strread(list, '%s');
	for i = 1 : length(files)
		mex('-c', files{i});
	end
	
	% support both .obj and .o extensions
	if exist(strrep(files{1}, '.c', '.obj'), 'file')
		linkList = strread(strrep(list, '.c', '.obj'), '%s');
	else
		linkList = strread(strrep(list, '.c', '.o'), '%s');
	end
	
	% link them
	mex(linkList{:});
	
end

	
end