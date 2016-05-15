%% Build documentation (using m2html library)
% L. LAURENT -- 07/02/2014 -- luc.laurent@lecnam.net

%load paths
dirPath=initDir;

%% Build documentation

%add configurtation to bash (for finding 'dot' script of graphviz)
setenv('BASH_ENV','~/.bash_profile');

%directory to be analysed
analyseDir='GRENAT';
%ignoring directory
%ignDir={'};

%listof files
listFiles=listFilesToolbox(dirPath);
%add path to all files
listFiles=cellfun(@(x) sprintf('%s/%s',analyseDir,x),listFiles,'UniformOutput',false);

cd ..
%execute generation of the doc (Graphviz is optional)
m2html('mfiles',listFiles,...
    'htmldir',[analyseDir '/doc'],...
    'recursive','on',...
    'global','on',...
    'globalHypertextLinks','on',...
    'index','menu',...
    'template','frame',...
    'index','menu',...
    'download','off',...
    'graph','on')
cd(analyseDir)
%%%%%%
