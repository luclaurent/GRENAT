%%initialization of the matlab2tikz's files (MATLAB's path)
%%L. LAURENT -- 13/04/2016  -- luc.laurent@lecnam.net

function init_matlab2tikz(pathcustom)

%directories in the PSOt toolbox
doss={'src'};

%if no specified directory
if nargin==0
    pathcustom=pwd;
end

%absolute path
absolute_path=cellfun(@(c)[pathcustom '/matlab2tikz/' c],doss,'uni',false);

%add to the PATH
cellfun(@addpath,absolute_path);

end
