%% Script de lancement et d'arret des workers (parrallelisme)
%% L. LAURENT -- 01/10/2012 -- luc.laurent@lecnam.net


function [ret]=exec_parallel(statut,options)

global parallel
parallel.actif=false;
parallel.num=0;

if usejava('jvm')
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
            
            arret=true;
            %%Si parallelisme reclame
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
                    fprintf(' >> Definition auto nombre de workers\n');
                end
                % chargement config par defaut
                def_parallel=findResource;
                if matlabpool('size')~=0
                    switch options.workers
                        case 'auto'
                            if matlabpool('size')>=def_parallel.ClusterSize
                                arret=false;
                            else
                                arret=true;
                            end
                        case 'manu'
                            if matlabpool('size')~=options.num_workers&&options.num_workers~=0
                                arret=true;
                            end
                    end
                    if arret
                        fprintf(' //!\\ MatLab parallel actif >>> ARRET\n');
                        matlabpool('close','force')
                        parallel.actif=false;
                        parallel.num=0;
                    else
                        fprintf(' //!\\ MatLab parallel actif >>> POURSUITE\n');
                    end
                    
                end
                %si parallelisme actif
                fprintf(' >>> Lancement workers MatLab Parallel <<<\n');
                %si lancement automatique
                if strcmp(options.workers,'auto')
                    %recuperation nombre de workers maxi
                    options.num_workers=def_parallel.ClusterSize;
                end
                %si lancement manuel
                if strcmp(options.workers,'manu')
                    fprintf(' >> Nombre de workers demandes/disponibles: %i/%i\n',options.num_workers,def_parallel.ClusterSize);
                    %verification nombre de workers demandes
                    if options.num_workers>def_parallel.ClusterSize;
                        options.num_workers=def_parallel.ClusterSize;
                    end
                end
                fprintf(' >> Demande de workers: %s\n',options.workers);
                fprintf(' >> Nombre de workers: %i\n',options.num_workers);
                %execution demande et lancement workers
                if arret
                    try
                        matlabpool('open',options.num_workers);
                        parallel.actif=true;
                        parallel.num=options.num_workers;
                    catch err
                        fprintf('##>> Probleme initialisation parallele <<##\n');
                        fprintf('##>> Lancement sans parallelisme <<##\n');
                    end
                end
            end
            
        case 'stop'
            if options.on
                if matlabpool('size')~=0
                    fprintf(' >>> Arret workers MatLab Parallel <<<\n');
                    matlabpool('close');
                    parallel.actif=false;
                    parallel.num=0;
                end
            end
    end
end