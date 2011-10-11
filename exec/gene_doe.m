%% Realisation des tirages
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function tirages=gene_doe(doe)

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
    % Latin Hypercube Sampling (à loi uniforme)
    case 'LHS'
        Xmin=esp(:,1);
        Xmax=esp(:,2);
        tirages=lhsu(Xmin,Xmax,prod(nbs(:)));
    % LHS avec stockage des données
    case 'LHS_manu'     
        %on verifie si le dossier de stockage existe (si non on le cree)
        if exist('LHS_MANU','dir')~=7
            unix('mkdir LHS_MANU');
        end

       %on verifie si le tirages existe deja (si oui on le charge/si non on le
        %genere et le sauvegarde)
        fi=['LHS_MANU/lhs_man_' doe.fct sprintf('_%d',nbs)];
        fich=[fi '.mat'];
        if exist(fich,'file')==2
            st=load(fich,'tir_save');
            tirages=st.tir_save;
        else
            Xmin=esp(:,1);
            Xmax=esp(:,2);
            tirages=lhsu(Xmin,Xmax,prod(nbs(:)));
            save(fi,'tirages');
        end
    % tirages aléatoires
    case 'rand'
        tirages=repmat(esp(:,1)',prod(nbs(:)),1)...
            +repmat(esp(:,2)'-esp(:,1)',prod(nbs(:)),1).*rand(prod(nbs(:)),nbv);
    otherwise
        error('le type de tirage nest pas defini');
end

%% affichage infos
fprintf(' >> type de tirages: %s\n',doe.type);
end