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
        on=true;
        numWorkers=[];
    end
    methods
        %constructor
        function obj=execParallel(stateIn,numW)
            fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
            fprintf('  Define Parallelism\n')
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
                fprintf('Too large number of required workers\n');
            elseif numReq<=0
                fprintf('Wrong number of required workers\n');
                numReq=1;
            end
            %choose the number of worker
            obj.numWorkers=min(numReq,obj.defaultParallel.NumWorkers);
            fprintf(' >> Number of workers required/available: %i/%i\n',obj.numWorkers,obj.defaultParallel.NumWorkers);
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
                    keyboard
                    parpool(obj.numWorkers);
                    fprintf(' >>> Parallel workers started <<<\n');
                catch
                    fprintf('##>> Parallel starting issue <<##\n');
                    fprintf('##>> Start without parallelism <<##\n');
                end
            end
        end
        %stop parallel workers
        function stop(obj)
            %load current cluster
            currentConf(obj);
            %close it if available
            if obj.on&&obj.currentParallel.NumWorkers>0
                fprintf(' >>> Stop parallel workers <<<\n');
                delete(gcp('nocreate'));
            else
                fprintf(' >>> Workers already stopped\n');
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
if ~javaOk;fprintf('>> Matlab started without java support (remove -nojvm flag)\n');end
if ~matlabOk;fprintf('>> Code run with Octave (no parallelism)\n');end
if ~parallelOk;fprintf('>> The Distibuted Computing Toolbox is unavailable\n');end
end

% function [ret]=execParallel(statut,options)
%
% global parallelData
% parallelData.on=false;
% parallelData.num=0;
%
% if usejava('jvm')&&~isOctave
%     %depending on the status
%     switch statut
%         case 'start'
%             %%is no specified options
%             if nargin==1
%                 options.on=[];
%                 options.workers=[];
%                 options.numWorkers=[];
%             end
%             %if missing or undefined options load specific configuration
%             if isfield(options,'on')
%                 if isempty(options.on);options.on=false;end
%             else
%                 options.on=false;
%             end
%
%             arret=true;
%             %%if parallelism is required
%             if options.on
%                 if isfield(options,'workers')
%                     if isempty(options.workers);options.workers='auto';end
%                 else
%                     options.workers='auto';
%                 end
%                 if isfield(options,'num_workers')
%                     if isempty(options.num_workers);
%                         options.workers='auto';
%                         options.numWorkers=0;
%                         fprintf('Automatic definition of the number of workers\n');
%                     end
%                 else
%                     options.numWorkers=0;
%                     options.workers='auto';
%                     fprintf(' >> Automatic definition of the number of workers\n');
%                 end
%                 % load default configuration
%                 defParallel=parcluster;
%                 %load current runing configuration
%                 curParallel=gcp('nocreate');
%                 if sum(size(curParallel))~=0
%                     switch options.workers
%                         case 'auto'
%                             if curParallel.NumWorkers>=defParallel.NumWorkers
%                                 arret=false;
%                             else
%                                 arret=true;
%                             end
%                         case 'manu'
%                             if curParallel.NumWorkers~=options.numWorkers&&options.numWorkers~=0
%                                 arret=true;
%                             end
%                     end
%                     if arret
%                         fprintf(' //!\\ Matlab parallel is active >>> STOP IT !!\n');
%                         parpool('close','force')
%                         parallelData.actif=false;
%                         parallelData.num=0;
%                     else
%                         fprintf(' //!\\ Matlab parallel is active >>> CONTINUE !!\n');
%                     end
%
%                 end
%                 %if parallelism is active
%                 fprintf(' >>> Start workers <<<\n');
%                 %if automatic staring
%                 if strcmp(options.workers,'auto')
%                     %catch maximum number of workers
%                     options.NumWorkers=defParallel.NumWorkers;
%                 end
%                 %if manual loading
%                 if strcmp(options.reqWorkers,'manu')
%                     fprintf(' >> Number of workers required/available: %i/%i\n',options.numWorkers,defParallel.ClusterSize);
%                     %check required number of workers
%                     if options.num_workers>defParallel.NumWorkers;
%                         options.num_workers=defParallel.NumWorkers;
%                     end
%                 end
%                 fprintf(' >> Required workers: %s\n',options.reqWorkers);
%                 fprintf(' >> Number of workers: %i\n',options.numWorkers);
%                 %execute starting/stopping and catch error
%                 disp('la')
%                 if arret
%                     try
%                         parpool(options.numWorkers);
%                         parallelData.on=true;
%                         parallelData.num=options.numWorkers;
%                     catch
%                         fprintf('##>> Parallel starting issue <<##\n');
%                         fprintf('##>> Start without parallelism <<##\n');
%                     end
%                 end
%             end
%
%         case 'stop'
%             %load current runing configuration
%             curParallel=gcp('nocreate');
%             if sum(size(curParallel))~=0
%                 fprintf(' >>> Stop parallel workers <<<\n');
%                 delete(gcp('nocreate'));
%                 parallelData.on=false;
%                 parallelData.num=0;
%             end
%     end
%
%     ret=parallelData;
% end