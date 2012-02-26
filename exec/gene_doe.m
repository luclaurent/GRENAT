%% Realisation des tirages
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function tirages=gene_doe(doe)
tic
% obtenir un "vrai" tirages pseudo aléatoire
s = RandStream('mt19937ar','Seed','shuffle');
RandStream.setGlobalStream(s);

fprintf('===== DOE =====\n');

%recupŽration bornes espace de conception
esp=doe.bornes;

%nombre de variables
nbv=size(esp,1);

%recuperation nombre d'échantillons souhaités
nbs=doe.nb_samples;

%geŽnŽeration des diffŽerents types de tirages
switch doe.type
    % plan factoriel complet
    case 'ffact'
        tirages=factorial_design(nbs,esp);
        % Latin Hypercube Sampling avec R (et préenrichissement)
    case 'LHS_R'
        Xmin=esp(:,1);
        Xmax=esp(:,2);
        tirages=lhsu_R(Xmin,Xmax,prod(nbs(:)));
        % Improved Hypercube Sampling avec R (et préenrichissement)
    case 'IHS_R'
        Xmin=esp(:,1);
        Xmax=esp(:,2);
        tirages=ihs_R(Xmin,Xmax,prod(nbs(:)));
        % Latin Hypercube Sampling (à loi uniforme)
    case 'LHS'
        Xmin=esp(:,1);
        Xmax=esp(:,2);
        tirages=lhsu(Xmin,Xmax,prod(nbs(:)));
        % LHS avec stockage des données
    case 'LHS_manu'
        Xmin=esp(:,1);
        Xmax=esp(:,2);
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
            tirages=lhsu(0*Xmin,0*Xmax+1,prod(nbs(:))); % on génére un tirage dans l'espace [0 1]
            save(fi,'tirages');
        end
        % on corrige le tirage pourobetnir le bon espace
        tirages=tirages.*repmat(Xmax(:)'-Xmin(:)',prod(nbs(:)),1)+repmat(Xmin(:)',prod(nbs(:)),1);
        
    case 'LHS_R_manu'
        Xmin=esp(:,1);
        Xmax=esp(:,2);
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
            tirages=lhsu_R(0*Xmin,0*Xmax+1,prod(nbs(:))); % on génére un tirage dans l'espace [0 1]
            save(fi,'tirages');
        end
        % on corrige le tirage pourobetnir le bon espace
        tirages=tirages.*repmat(Xmax(:)'-Xmin(:)',prod(nbs(:)),1)+repmat(Xmin(:)',prod(nbs(:)),1);
        
    case 'IHS_R_manu'
        Xmin=esp(:,1);
        Xmax=esp(:,2);
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
            tirages=ihs_r(0*Xmin,0*Xmax+1,prod(nbs(:))); % on génére un tirage dans l'espace [0 1]
            save(fi,'tirages');
        end
        % on corrige le tirage pourobetnir le bon espace
        tirages=tirages.*repmat(Xmax(:)'-Xmin(:)',prod(nbs(:)),1)+repmat(Xmin(:)',prod(nbs(:)),1);
        % tirages aléatoires
    case 'rand'
        tirages=repmat(esp(:,1)',prod(nbs(:)),1)...
            +repmat(esp(:,2)'-esp(:,1)',prod(nbs(:)),1).*rand(prod(nbs(:)),nbv);
        %tirages définis manuellement
    case 'perso'
        tirages=doe.manu;
        disp('/!\ Echantillonnage manuel (cf. conf_doe.m)');
    otherwise
        error('le type de tirage nest pas defini');
end

%Tri des tirages (par rapport à une variable
if isfield(doe,'tri')&&doe.tri>0
    if doe.tri<=size(tirages,1)
        [~,ind]=sort(tirages(:,doe.tri));
        tirages=tirages(ind,:);
    else
        fprintf('###############################################################\n');
        fprintf('## ##mauvais paramètre de tri des tirages (tri désactivé) ## ##\n');
        fprintf('###############################################################\n');
    end
end

toc

%affichage tirages
aff_doe(tirages,doe)

%% affichage infos
fprintf(' >> type de tirages: %s\n',doe.type);
end