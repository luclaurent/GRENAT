%% Function for checking the status of the parallelism
%% L. LAURENT -- 24/01/2014 -- luc.laurent@lecnam.net

function [statusP,num]=statusParallel
%status
statusP=false;
num=0;
%check if the global variable is availbale, if not : no parallelism
if ~isempty(whos('global','parallel'));
    global parallel;
    statusP=parallel.on;
    if statusP
        num=Inf;
    end
end
end