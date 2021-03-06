
%% Method of execParallel class
% L. LAURENT -- 01/10/2012 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017-2017  Luc LAURENT <luc.laurent@lecnam.net>
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.


%% start parallel workers
% INPUTS:
% - none
% OUTPUTS:
% - none

function start(obj)
%load the current configuration
flagCurrent=obj.currentConf;
%if not defined fix the number of workers at the default value
if isempty(obj.numWorkers)
    obj.defNumWorkers;
end
%if yes, check the size of it
if obj.currentParallel.NumWorkers~=obj.numWorkers&&flagCurrent
    stop(obj);
end
%now start the cluster
try
    parpool(obj.numWorkers);
    Gfprintf(' >>> Parallel workers started <<<\n');
    obj.on=true;
catch
    Gfprintf('##>> Parallel starting issue <<##\n');
    Gfprintf('##>> Start without parallelism <<##\n');
end
end
