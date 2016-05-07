%% Script for starting & stopping workers (parallel)
%% L. LAURENT -- 01/10/2012 -- luc.laurent@lecnam.net

function [ret]=execParallel(statut,options)

global parallelData
parallelData.on=false;
parallelData.num=0;

if usejava('jvm')
    %depending on the status
    switch statut
        case 'start'
            %%is no specified options
            if nargin==1
                options.on=[];
                options.workers=[];
                options.numWorkers=[];
            end
            %if missing or undefined options load specific configuration
            if isfield(options,'on')
                if isempty(options.on);options.on=false;end
            else
                options.on=false;
            end
            
            arret=true;
            %%if parallelism is required
            if options.on
                if isfield(options,'workers')
                    if isempty(options.workers);options.workers='auto';end
                else
                    options.workers='auto';
                end
                if isfield(options,'num_workers')
                    if isempty(options.num_workers);
                        options.workers='auto';
                        options.numWorkers=0;
                        fprintf('Automatic definition of the number of workers\n');
                    end
                else
                    options.numWorkers=0;
                    options.workers='auto';
                    fprintf(' >> Automatic definition of the number of workers\n');
                end
                % load default configuration
                defParallel=parcluster;
                %load current runing configuration
                curParallel=gcp('nocreate');
                if sum(size(curParallel))~=0
                    switch options.workers
                        case 'auto'
                            if curParallel.NumWorkers>=defParallel.NumWorkers
                                arret=false;
                            else
                                arret=true;
                            end
                        case 'manu'
                            if curParallel.NumWorkers~=options.numWorkers&&options.numWorkers~=0
                                arret=true;
                            end
                    end
                    if arret
                        fprintf(' //!\\ Matlab parallel is active >>> STOP IT !!\n');
                        parpool('close','force')
                        parallelData.actif=false;
                        parallelData.num=0;
                    else
                        fprintf(' //!\\ Matlab parallel is active >>> CONTINUE !!\n');
                    end
                    
                end
                %if parallelism is active
                fprintf(' >>> Start workers <<<\n');
                %if automatic staring
                if strcmp(options.workers,'auto')
                    %catch maximum number of workers
                    options.NumWorkers=defParallel.NumWorkers;
                end
                %if manual loading
                if strcmp(options.reqWorkers,'manu')
                    fprintf(' >> Number of workers required/available: %i/%i\n',options.numWorkers,defParallel.ClusterSize);
                    %check required number of workers
                    if options.num_workers>defParallel.NumWorkers;
                        options.num_workers=defParallel.NumWorkers;
                    end
                end
                fprintf(' >> Required workers: %s\n',options.reqWorkers);
                fprintf(' >> Number of workers: %i\n',options.numWorkers);
                %execute starting/stopping and catch error
                disp('la')
                if arret
                    try
                        parpool(options.numWorkers);
                        parallelData.on=true;
                        parallelData.num=options.numWorkers;
                    catch 
                        fprintf('##>> Parallel starting issue <<##\n');
                        fprintf('##>> Start without parallelism <<##\n');
                    end
                end
            end
            
        case 'stop'
            %load current runing configuration
            curParallel=gcp('nocreate');
            if sum(size(curParallel))~=0
                fprintf(' >>> Stop parallel workers <<<\n');
                delete(gcp('nocreate'));
                parallelData.on=false;
                parallelData.num=0;
            end
    end
    
    ret=parallelData;
end