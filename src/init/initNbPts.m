%% Function for calculating th right number of sample points for the reference grid
% used for evaluating the surrogate model (avoid to large number)
%% L.LAURENT -- 15/05/2012 -- luc.laurent@lecnam.net

function nbV=initNbPts(dim)

if dim==1
    nbV=200;
elseif dim==2
    nbV=30;
elseif dim==3
    nbV=10;
elseif dim==4
    nbV=6;
elseif dim==5;
    nbV=4;
elseif dim>=6
    nbV=3;  
else 
    fprintf('##############################\n');
    fprintf('### The dimension of the problem is too large:\n')
    fprintf('### Unable to generate the the right number of\n')
    fprintf('### sample points for the reference grid\n')
    fprintf(['### Define it manually (or See',mfilename,')\n'])
    fprintf('##############################\n');
    nbV=NaN;
end