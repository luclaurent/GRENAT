%% Script for starting & stopping workers (parallel)
% L. LAURENT -- 01/10/2012 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016  Luc LAURENT <luc.laurent@lecnam.net>
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

classdef execParallel < handle
    properties
        workers=[];
        defaultParallel=[];
        currentParallel=[];
        on=false;
        numWorkers=[];
    end
    methods
        %constructor
        function obj=execParallel(stateIn,numW)
            Gfprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n');
            Gfprintf('Define Parallelism\n');
            %depending of the input arguments
            if nargin>0;obj.on=stateIn;end
            if checkRun&&obj.on
                %load default configuration
                defaultConf(obj);
                %initialize value
                if nargin>1;obj.numWorkers=numW;else obj.numWorkers=obj.defaultParallel.NumWorkers;end
                %run in specific case
                if nargin==0;start(obj);end
            end
            %load current configuration
            if nargin==0
                currentConf(obj);
                %initialize value
                obj.numWorkers=obj.currentParallel.NumWorkers;
            end                
        end
        %setter for on
        function set.on(obj,stateIn)
            %check previous state and new required state
            if ~obj.on&&stateIn
                %load default configuration
                defaultConf(obj);
                %set number of workers
            obj.numWorkers=obj.defaultParallel.NumWorkers;
            end
            %set state of parallelism
            obj.on=stateIn;
        end
        %setter for numWorkers
        function set.numWorkers(obj,numReq)
            %check if the default configuration is already loaded
            if isempty(obj.defaultParallel);defaultConf(obj);end
            %check if the required number of workers is available
            if numReq>obj.defaultParallel.NumWorkers
                Gfprintf('Too large number of required workers\n');
            elseif numReq<=0
                Gfprintf('Wrong number of required workers\n');
                numReq=1;
            end
            %choose the number of worker
            obj.numWorkers=min(numReq,obj.defaultParallel.NumWorkers);
            Gfprintf(' >> Number of workers required/available: %i/%i\n',obj.numWorkers,obj.defaultParallel.NumWorkers);
        end
        %start parallel workers
        function start(obj)
            if obj.on
                %check if a cluster is already running
                currentConf(obj);
                %if yes, check the size of it
                if obj.currentParallel.NumWorkers~=obj.numWorkers
                    stop(obj);
                end
                %now start the cluster
                try
                    parpool(obj.numWorkers);
                    Gfprintf(' >>> Parallel workers started <<<\n');
                catch
                    Gfprintf('##>> Parallel starting issue <<##\n');
                    Gfprintf('##>> Start without parallelism <<##\n');
                end
            end
        end
        %stop parallel workers
        function stop(obj)
            %load current cluster
            currentConf(obj);
            %close it if available
            if obj.on&&obj.currentParallel.NumWorkers>0
                Gfprintf(' >>> Stop parallel workers <<<\n');
                delete(gcp('nocreate'));
            else
                Gfprintf(' >>> Workers already stopped\n');
            end
        end
        %load default configuration
        function defaultConf(obj)
            obj.defaultParallel=parcluster;
        end
        %load current configuration
        function currentConf(obj)
            p=gcp('nocreate');
            %none current parallel cluster defined
            if isempty(p)
                obj.currentParallel.NumWorkers=0;
            else
                obj.currentParallel=p;
            end
        end
    end
end


%check if the parallel toolbox is available, if java is loaded and
%if the function is executed in matlab
function runOk=checkRun()
javaOk=usejava('jvm');
matlabOk=~isOctave;
parallelOk=license('test','Distrib_Computing_Toolbox');
runOk=javaOk&matlabOk&parallelOk;
if ~javaOk;Gfprintf('>> Matlab started without java support (remove -nojvm flag)\n');end
if ~matlabOk;Gfprintf('>> Code run with Octave (no parallelism)\n');end
if ~parallelOk;Gfprintf('>> The Distibuted Computing Toolbox is unavailable\n');end
end

