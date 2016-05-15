%%initialization of the matlab2tikz's files (MATLAB's path)
%%L. LAURENT -- 13/04/2016  -- luc.laurent@lecnam.net

function initMatlab2tikz(pathCustom)

%directories in the matlab2tikz toolbox
folderToolbox={'src'};

if exist(pathCustom,'dir')
    %if no specified directory
    if nargin==0
        pathCustom=pwd;
    end
    
    %absolute path
    absolutePath=cellfun(@(c)[pathCustom '/matlab2tikz/' c],folderToolbox,'uni',false);
    
    %add to the PATH
    cellfun(@addpath,absolutePath);
    
    %display
    fprintf(' ## Toolbox: matlab2tikz loaded\n');
end
end
