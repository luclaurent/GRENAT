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
        defNumWorkers(obj);
        %% function for getting manually the number of workers
        nbW=getDefNumWorkers(obj);
        %% Function for checking if default configuration has been already
        %loaded
        fl=checkLoadDef(obj);
        %% start parallel workers
        start(obj);
        %% Stop parallel workers
        stop(obj);
        %% Load default configuration
        defaultConf(obj);
        %% Load current configuration
        flag=currentConf(obj);
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