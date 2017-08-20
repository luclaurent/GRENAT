%% Script for starting & stopping workers (parallel)
% L. LAURENT -- 01/10/2012 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017  Luc LAURENT <luc.laurent@lecnam.net>
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
        defaultParallel=[];     % default configuration accepted by the computer
        currentParallel=[];     % current configuration 
        on=true;                % flag for running or not the pool
        numWorkers=[];          % number of required workers 
    end
    methods
        %% Constructor
        % INPUTS (in any order and optional)
        % - a boolean value for starting or not directly the parallel pool
        % - an integer for specifying the number of required workers
        function obj=execParallel(varargin)
            Gfprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n');
            if checkRun
                Gfprintf('Define Parallelism\n');
                %load the default configuration
                obj.defaultConf;
                % deal with input arguments
                if nargin>0
                    %scan input arguments
                    %boolean
                    boolC=cellfun(@islogical,varargin);
                    %integer
                    intC=cellfun(@isnumeric,varargin);
                    %
                    if any(boolC)
                        obj.on=varargin{boolC};
                    end
                    %initialize value
                    if any(intC)
                        obj.numWorkers=varargin{intC};
                    end
                end
                % start or not
                if obj.on
                    obj.start;
                else
                    obj.stop;
                end
            else
                %kill the object because the initialization is not possible
                delete(obj);
            end
        end
        %% setter for on
        function set.on(obj,stateIn)
            %check previous state and new required state
            if ~obj.on&&stateIn
                %load default configuration
                defaultConf(obj);
                %set number of workers
                obj.defNumWorkers;
            end
            %set state of parallelism
            obj.on=stateIn;
        end
        %% setter for numWorkers
        function set.numWorkers(obj,numReq)
            %check if the default configuration is already loaded
            if obj.checkLoadDef;defaultConf(obj);end
            %check if the required number of workers is available
            if numReq>obj.getDefNumWorkers
                Gfprintf('Too large number of required workers\n');
            elseif numReq<=0
                Gfprintf('Wrong number of required workers\n');
                numReq=1;
            end
            %choose the number of worker
            obj.numWorkers=min(numReq,obj.getDefNumWorkers);
            Gfprintf(' >> Number of workers required/available: %i/%i\n',obj.numWorkers,obj.getDefNumWorkers);
        end
        %% force number of workers to the default value
        function defNumWorkers(obj)
            obj.numWorkers=obj.getDefNumWorkers;
        end
        
        %% function for getting manually the number of workers
        function nbW=getDefNumWorkers(obj)
            nbW=obj.defaultParallel.NumWorkers;
        end
        
        %% Function for checking if default configuration has been already
        %loaded
        function fl=checkLoadDef(obj)
            fl=isempty(obj.defaultParallel);
        end
        
        %% start parallel workers
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
        %% Stop parallel workers
        function stop(obj)
            %load current cluster
            currentConf(obj);
            %close it if available
            if obj.currentParallel.NumWorkers>0
                Gfprintf(' >>> Stop parallel workers <<<\n');
                delete(gcp('nocreate'));
            else
                Gfprintf(' >>> Workers already stopped\n');
            end
        end
        %% Load default configuration
        function defaultConf(obj)
            obj.defaultParallel=parcluster;
        end
        %% Load current configuration
        function flag=currentConf(obj)
            flag=false;
            p=[];
            if exist('gcp','file')
                p=gcp('nocreate');
            end
            %none current parallel cluster defined
            if isempty(p)
                obj.currentParallel.NumWorkers=0;
            else
                obj.currentParallel=p;
                flag=true;
            end
        end
    end
end


%%check if the parallel toolbox is available, if java is loaded and
% if the function is executed in matlab
function runOk=checkRun()
javaOk=usejava('jvm');
matlabOk=~isOctave;
parallelOk=license('test','Distrib_Computing_Toolbox');
runOk=javaOk&matlabOk&parallelOk;
if ~javaOk;Gfprintf('>> Matlab started without java support (remove -nojvm flag)\n');end
if ~matlabOk;Gfprintf('>> Code run with Octave (no parallelism)\n');end
if ~parallelOk;Gfprintf('>> The Distibuted Computing Toolbox is unavailable\n');end
end

