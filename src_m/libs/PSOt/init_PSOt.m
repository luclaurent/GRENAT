%%initialization of the PSOt's files (MATLAB's path)
%%L. LAURENT -- 31/01/2014  -- luc.laurent@lecnam.net

function init_PSOt(pathcustom)

%directories in the PSOt toolbox
doss={'hiddenutils','nnet','testfunctions'};

%if no specified directory
if nargin==0
    pathcustom=pwd;
end

%absolute path
absolute_path=cellfun(@(c)[pathcustom '/' c],doss,'uni',false);

%add to the PATH
cellfun(@addpath,absolute_path);

end
