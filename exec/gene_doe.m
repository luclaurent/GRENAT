%% Realisation des tirages
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function tirages=gene_doe(doe)


fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
fprintf('    >>> GENERATION TIRAGES <<<\n');
[tMesu,tInit]=mesu_time;

% obtenir un "vrai" tirages pseudo aleatoire
s = RandStream('mt19937ar','Seed','shuffle');
RandStream.setGlobalStream(s);

fprintf('===== DOE =====\n');

%recuperation bornes espace de conception
if isfield(doe,'Xmin')&&isfield(doe,'Xmax')
    Xmin=doe.Xmin;
    Xmax=doe.Xmax;
elseif isfield(doe,'bornes')
    Xmin=doe.bornes(:,1);
    Xmax=doe.bornes(:,2);
end

%nombre de variables
nbv=numel(Xmin);

%recuperation nombre d'echantillons souhaites
nbs=doe.nb_samples;



%generation des differents types de tirages
switch doe.type
    % plan factoriel complet
    case 'ffact'
        tirages=factorial_design(nbs,doe.bornes);
        % Latin Hypercube Sampling avec R (et preenrichissement)
    case 'LHS_R'
        tirages=lhsu_R(Xmin,Xmax,prod(nbs(:)));
        % Improved Hypercube Sampling
    case 'IHS'
        tirages=ihs(nbv,nbs,5,17);
        tirages=tirages./nbs;
        tirages=tirages';
        tirages=tirages.*repmat(Xmax(:)'-Xmin(:)',nbs,1)+repmat(Xmin(:)',nbs,1);
        % Improved Hypercube Sampling avec R (et preenrichissement)
    case 'IHS_R'
        tir=ihs_R(Xmin,Xmax,prod(nbs(:)));
        tirages=tir(1:nbs,:).*repmat(Xmax(:)'-Xmin(:)',nbs,1)+repmat(Xmin(:)',nbs,1);
        % Latin Hypercube Sampling (� loi uniforme)
    case 'LHS'
        tirages=lhsu(Xmin,Xmax,prod(nbs(:)));
        % LHS avec stockage des donnees
    case 'LHS_manu'
        %on verifie si le dossier de stockage existe (si non on le cree)
        if exist('TIR_MANU','dir')~=7
            unix('mkdir TIR_MANU');
        end
        
        %on verifie si le tirages existe deja (si oui on le charge/si non on le
        %genere et le sauvegarde)
        fi=['TIR_MANU/lhsu_man_' num2str(nbv) '_'  num2str(nbs)];
        fich=[fi '.mat'];
        if exist(fich,'file')==2
            st=load(fich);
            tirages=st.tirages;
        else
            fprintf('Tirage inexistant >> execution!!\n')
            tirages=lhsu(0*Xmin,0*Xmax+1,prod(nbs(:))); % on g�n�re un tirage dans l'espace [0 1]
            save(fi,'tirages');
        end
        % on corrige le tirage pourobetnir le bon espace
        tirages=tirages.*repmat(Xmax(:)'-Xmin(:)',prod(nbs(:)),1)+repmat(Xmin(:)',prod(nbs(:)),1);
        
    case 'LHS_R_manu'
        %on verifie si le dossier de stockage existe (si non on le cree)
        if exist('TIR_MANU','dir')~=7
            unix('mkdir TIR_MANU');
        end
        
        %on verifie si le tirages existe deja (si oui on le charge/si non on le
        %genere et le sauvegarde)
        fi=['TIR_MANU/lhsuR_man_' num2str(nbv) '_'  num2str(nbs)];
        fich=[fi '.mat'];
        if exist(fich,'file')==2
            st=load(fich);
            tirages=st.tirages;
        else
            fprintf('Tirage inexistant >> execution!!\n')
            tirages=lhsu_R(0*Xmin,0*Xmax+1,prod(nbs(:))); % on g�n�re un tirage dans l'espace [0 1]
            save(fi,'tirages');
        end
        % on corrige le tirage pourobetnir le bon espace
        tirages=tirages.*repmat(Xmax(:)'-Xmin(:)',prod(nbs(:)),1)+repmat(Xmin(:)',prod(nbs(:)),1);
        
    case 'IHS_R_manu'
        %on verifie si le dossier de stockage existe (si non on le cree)
        if exist('TIR_MANU','dir')~=7
            unix('mkdir TIR_MANU');
        end
        
        %on verifie si le tirages existe deja (si oui on le charge/si non on le
        %genere et le sauvegarde)
        fi=['TIR_MANU/ihsR_man_' num2str(nbv) '_'  num2str(nbs)];
        fich=[fi '.mat'];
        if exist(fich,'file')==2
            st=load(fich);
            tirages=st.tirages;
        else
            fprintf('Tirage inexistant >> execution!!\n')
            tirages=ihs_R(0*Xmin,0*Xmax+1,prod(nbs(:))); % on g�n�re un tirage dans l'espace [0 1]
            save(fi,'tirages');
        end
        % on corrige le tirage pourobetnir le bon espace
        tirages=tirages.*repmat(Xmax(:)'-Xmin(:)',prod(nbs(:)),1)+repmat(Xmin(:)',prod(nbs(:)),1);
        % tirages al�atoires
    case 'IHS_R_manu_enrich'
        %on verifie si le dossier de stockage existe (si non on le cree)
        if exist('TIR_MANU','dir')~=7
            unix('mkdir TIR_MANU');
        end
        
        %on verifie si le tirages existe deja (si oui on le charge/si non on le
        %genere et le sauvegarde)
        fi=['TIR_MANU/ihsR_man_' num2str(nbv) '_'  num2str(doe.nbs_min) '_' num2str(doe.nbs_max)];
        fich=[fi '.mat'];
        if exist(fich,'file')==2
            st=load(fich);
            tirages=st.tirages;
        else
            fprintf('Tirage inexistant >> execution!!\n')
            t_init=ihs_R(0*Xmin,0*Xmax+1,doe.nbs_min); % on initialise le tirage
            [tirages,~]=ihs_R(0*Xmin,0*Xmax+1,doe.nbs_min,t_init,doe.nbs_max);
            save(fi,'tirages');
        end
        % on corrige le tirage pourobetnir le bon espace
        tirages=tirages(1:nbs,:).*repmat(Xmax(:)'-Xmin(:)',prod(nbs(:)),1)+repmat(Xmin(:)',prod(nbs(:)),1);
        % tirages al�atoires
    case 'LHS_R_manu_enrich'
        %on verifie si le dossier de stockage existe (si non on le cree)
        if exist('TIR_MANU','dir')~=7
            unix('mkdir TIR_MANU');
        end
        
        %on verifie si le tirages existe deja (si oui on le charge/si non on le
        %genere et le sauvegarde)
        fi=['TIR_MANU/lhsuR_man_' num2str(nbv) '_'  doe.nbs_min '_' doe.nbs_max];
        fich=[fi '.mat'];
        if exist(fich,'file')==2
            st=load(fich);
            tirages=st.tirages;
        else
            fprintf('Tirage inexistant >> execution!!\n')
            t_init=lhsu_R(0*Xmin,0*Xmax+1,doe.nbs_min); % on initialise le tirage
            [tirages,~]=lhsu_R(0*Xmin,0*Xmax+1,doe.nbs_min,t_init,doe.nbs_max);
            save(fi,'tirages');
        end
        % on corrige le tirage pourobetnir le bon espace
        tirages=tirages(1:nbs,:).*repmat(Xmax(:)'-Xmin(:)',prod(nbs(:)),1)+repmat(Xmin(:)',prod(nbs(:)),1);
        % tirages al�atoires
    case 'rand'
        tirages=repmat(esp(:,1)',prod(nbs(:)),1)...
            +repmat(esp(:,2)'-esp(:,1)',prod(nbs(:)),1).*rand(prod(nbs(:)),nbv);
        %tirages d�finis manuellement
    case 'perso'
        tirages=doe.manu;
        disp('/!\ Echantillonnage manuel (cf. conf_doe.m)');
    otherwise
        error('le type de tirage nest pas defini');
end

%Tri des tirages (par rapport � une variable
if isfield(doe,'tri')&&doe.tri>0
    if doe.tri<=size(tirages,1)
        [~,ind]=sort(tirages(:,doe.tri));
        tirages=tirages(ind,:);
    else
        fprintf('###############################################################\n');
        fprintf('## ##mauvais param�tre de tri des tirages (tri d�sactiv�) ## ##\n');
        fprintf('###############################################################\n');
    end
end


%affichage tirages
aff_doe(tirages,doe)

%% affichage infos
fprintf(' >> type de tirages: %s\n',doe.type);

mesu_time(tMesu,tInit);
fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
end