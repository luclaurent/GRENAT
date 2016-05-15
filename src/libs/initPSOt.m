%%initialization of the PSOt's files (MATLAB's path)
%%L. LAURENT -- 31/01/2014  -- luc.laurent@lecnam.net

function initPSOt(pathCustom)

%directories in the PSOt toolbox
folderToolbox={'hiddenutils','nnet','testfunctions'};

if exist(pathCustom,'dir')
    
    %if no specified directory
    if nargin==0
        pathCustom=pwd;
    end
    
    %absolute path
    absolutePath=cellfun(@(c)[pathCustom '/' c],folderToolbox,'uni',false);
    
    %add to the PATH
    cellfun(@addpath,absolutePath);
    
    %display
    fprintf(' ## Toolbox: PSOt loaded\n');
end
end
