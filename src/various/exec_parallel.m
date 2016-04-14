%% Script for starting & stopping workers (parallel)
%% L. LAURENT -- 01/10/2012 -- luc.laurent@lecnam.net

function [ret]=exec_parallel(statut,options)

global parallel
parallel.on=false;
parallel.num=0;

if usejava('jvm')
    %depending on the status
    switch statut
        case 'start'
            %%is no specified options
            if nargin==1
                options.on=[];
                options.workers=[];
                options.num_workers=[];
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
                    if isempty(options.num_workers);options.workers='auto';options.num_workers=0;fprintf('Definition auto nombre de workers\n');end
                else
                    options.num_workers=0;
                    options.workers='auto';
                    fprintf(' >> Automatic definition of the number of workers\n');
                end
                % load default configuration
                def_parallel=parcluster;
                %load current runing configuration
                cur_parallel=gcp('nocreate');
                if sum(size(cur_parallel))~=0
                    switch options.workers
                        case 'auto'
                            if cur_parallel.NumWorkers>=def_parallel.NumWorkers
                                arret=false;
                            else
                                arret=true;
                            end
                        case 'manu'
                            if cur_parallel.NumWorkers~=options.num_workers&&options.num_workers~=0
                                arret=true;
                            end
                    end
                    if arret
                        fprintf(' //!\\ Matlab parallel is active >>> STOP IT !!\n');
                        parpool('close','force')
                        parallel.actif=false;
                        parallel.num=0;
                    else
                        fprintf(' //!\\ Matlab parallel is active >>> CONTINUE !!\n');
                    end
                    
                end
                %if parallelism is active
                fprintf(' >>> Start workers <<<\n');
                %if automatic staring
                if strcmp(options.workers,'auto')
                    %catch maximum number of workers
                    options.num_workers=def_parallel.NumWorkers;
                end
                %if manual loading
                if strcmp(options.workers,'manu')
                    fprintf(' >> Number of workers required/available: %i/%i\n',options.num_workers,def_parallel.ClusterSize);
                    %verification nombre de workers demandes
                    if options.num_workers>def_parallel.NumWorkers;
                        options.num_workers=def_parallel.NumWorkers;
                    end
                end
                fprintf(' >> Required workers: %s\n',options.workers);
                fprintf(' >> Number of workers: %i\n',options.num_workers);
                %execute starting/stopping and catch error
                disp('la')
                if arret
                    try
                        parpool(options.num_workers);
                        parallel.actif=true;
                        parallel.num=options.num_workers;
                    catch err
                        fprintf('##>> Parallel starting issue <<##\n');
                        fprintf('##>> Start without parallelism <<##\n');
                    end
                end
            end
            
        case 'stop'
            %load current runing configuration
            cur_parallel=gcp('nocreate');
            if sum(size(cur_parallel))~=0
                fprintf(' >>> Stop parallel workers <<<\n');
                delete(gcp('nocreate'));
                parallel.actif=false;
                parallel.num=0;
            end
    end
end