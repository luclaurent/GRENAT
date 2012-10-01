%% Script de lancement et d'arret des workers (parrallelisme)
%% L. LAURENT -- 01/10/2012 -- laurent@lmt.ens-cachan.fr


function [ret]=exec_parallel(statut,options)

%en fonction du statut
switch statut
    case 'start'
        %%si pas d'options specifies
        if nargin==1
            options.on=[];
            options.workers=[];
            options.num_workers=[];
        end
        %si options manquantes ou non definies:chargement configuration
        %particuliere
        if isfield(options,'on')
            if isempty(options.on);options.on=false;end
        else
            options.on=false;
        end
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
            fprintf(' >> Definition auto nombre de workers\n');
        end
        %%Si parallelisme reclame
        if options.on
            fprintf(' >>> Lancement workers MatLab Parallel <<<\n');
            % chargement config par defaut
            def_parallel=findResource;
            %si lancement automatique
            if strcmp(options.workers,'auto')
                %recuperation nombre de workers maxi
                options.num_workers=def_parallel.ClusterSize;
            end
            %si lancement manuel
            if strcmp(options.workers,'manu')
                fprintf(' >> Nombre de workers demandes/disponibles: %i/%i\n',options.num_workers,def_parallel.NumWorkers);
                %verification nombre de workers demandes
                if options.num_workers>def_parallel.ClusterSize;
                    options.num_workers=def_parallel.ClusterSize;
                end
            end  
            fprintf(' >> Demande de workers: %s\n',options.workers);
            fprintf(' >> Nombre de workers: %i\n',options.num_workers);
            %execution demande et lancement workers
            matlabpool('open',options.num_workers);
        end
        
    case 'stop'
        fprintf(' >>> Arret workers MatLab Parallel <<<\n');
        matlabpool('close');
end