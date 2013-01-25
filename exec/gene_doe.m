%% Realisation des tirages
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

%certains criteres necessitent la toolbox "Random Numbers Generators" ou
%l'installation de R sur votre machine
%tous les tirages generent des points entre 0 et 1. La correction est faite
%a la fin

function tirages=gene_doe(doe)


fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
fprintf('    >>> GENERATION TIRAGES <<<\n');
[tMesu,tInit]=mesu_time;

% obtenir un "vrai" tirages pseudo aleatoire
s = RandStream('mt19937ar','Seed','shuffle');
RandStream.setGlobalStream(s);

fprintf('===== DOE =====\n');

%recuperation nombre d'echantillons souhaites
nbs=doe.nb_samples;

%recuperation nombre iteration si specifie
if isfield(doe,'iter');nb_iter=doe.iter;else nb_iter=5;end

%nombre de generation pour LHS score
nb_gene=20;

%recuperation bornes espace de conception
if isfield(doe,'Xmin')&&isfield(doe,'Xmax')
    Xmin=doe.Xmin;
    Xmax=doe.Xmax;
elseif isfield(doe,'bornes')
    Xmin=doe.bornes(:,1);
    Xmax=doe.bornes(:,2);
end
%valeurs par defaut
Xmin_def=0.*Xmin;Xmax_def=0.*Xmax+1;

%nombre de variables
nbv=numel(Xmin);

%% affichage infos
fprintf(' >> type de tirages: %s\n',doe.type);
fprintf(' >> Nombre de points: %i\n',nbs);
fprintf(' >> Nombre de variables: %i\n',nbv);

tir_ok=true;
tir_perso=false;
%generation des differents types de tirages
switch doe.type
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plan factoriel complet
    case 'ffact'
        tirages=factorial_design(nbs,Xmin_def,Xmax_def);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Latin Hypercube Sampling avec R (et preenrichissement)
    case 'LHS_R'
        tirages=lhsu_R(Xmin_def,Xmax_def,prod(nbs(:)));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'LHS_R_manu'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('lhsuR',nbv,nbs);
        if isempty(tirages)
            tirages=lhsu_R(Xmin_def,Xmax_def,prod(nbs(:))); % on g�n�re un tirage dans l'espace [0 1]
            save(fich,'tirages');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Optimum Latin Hypercube Sampling avec R (et preenrichissement)
    case 'OLHS_R'
        tirages=olhs_R(Xmin_def,Xmax_def,prod(nbs(:)));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'OLHS_R_manu'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('olhsR',nbv,nbs);
        if isempty(tirages)
            tirages=olhs_R(Xmin_def,Xmax_def,prod(nbs(:))); % on g�n�re un tirage dans l'espace [0 1]
            save(fich,'tirages');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Maximin Latin Hypercube Sampling avec R (et preenrichissement)
    case 'MMLHS_R'
        tirages=mmlhs_R(Xmin_def,Xmax_def,prod(nbs(:)));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'MMLHS_R_manu'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('mmlhsR',nbv,nbs);
        if isempty(tirages)
            tirages=mmlhs_R(Xmin_def,Xmax_def,prod(nbs(:))); % on g�n�re un tirage dans l'espace [0 1]
            save(fich,'tirages');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Genetic Latin Hypercube Sampling avec R (et preenrichissement)
    case 'GLHS_R'
        tirages=glhs_R(Xmin_def,Xmax_def,prod(nbs(:)));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'GLHS_R_manu'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('glhsR',nbv,nbs);
        if isempty(tirages)
            tirages=lhsu_R(Xmin_def,Xmax_def,prod(nbs(:))); % on g�n�re un tirage dans l'espace [0 1]
            save(fich,'tirages');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Improved Hypercube Sampling avec R (et preenrichissement)
    case 'IHS_R'
        tirages=ihs_R(Xmin_def,Xmax_def,prod(nbs(:)));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'IHS_R_manu'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('ihsR',nbv,nbs);
        if isempty(tirages)
            tirages=lhsu_R(Xmin_def,Xmax_def,prod(nbs(:))); % on g�n�re un tirage dans l'espace [0 1]
            save(fich,'tirages');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Tirage sequence de Halton (fct Matlab)
    case 'HALTON'
        p = haltonset(nbv,'Skip',1e3,'Leap',1e2);
        p = scramble(p,'RR2');
        tirages=net(p,prod(nbs(:)));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Halton avec stockage des donnees
    case 'HALTON_manu'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('halton',nbv,nbs);
        if isempty(tirages)
            p = haltonset(nbv,'Skip',1e3,'Leap',1e2);
            p = scramble(p,'RR2');
            tirages=net(p,prod(nbs(:)));
            save(fich,'tirages');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Tirage sequence de Sobol (fct Matlab)
    case 'SOBOL'
        p = sobolset(nbv,'Skip',1e3,'Leap',1e2);
        p = scramble(p,'MatousekAffineOwen');
        tirages=net(p,prod(nbs(:)));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Sobol avec stockage des donnees
    case 'SOBOL_manu'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('sobol',nbv,nbs);
        if isempty(tirages)
            p = sobolset(nbv,'Skip',1e3,'Leap',1e2);
            p = scramble(p,'MatousekAffineOwen');
            tirages=net(p,prod(nbs(:)));
            save(fich,'tirages');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Latin Hypercube Sampling (fonction Matlab)
    case 'LHSD'
        tirages=lhsdesign(prod(nbs(:)),nbv,'iterations',nb_iter);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % LHS avec stockage des donnees
    case 'LHSD_manu'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('lhsd',nbv,nbs);
        if isempty(tirages)
            tirages=lhsdesign(prod(nbs(:)),nbv,'iterations',nb_iter);
            save(fich,'tirages');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Latin Hypercube Sampling (fonction Matlab) minimisation correlation (cf help)
    case 'LHSD_CORRMIN'
        tirages=lhsdesign(prod(nbs(:)),nbv,'criterion','correlation','iterations',nb_iter);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % LHS avec stockage des donnees
    case 'LHSD_CORRMIN_manu'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('lhsdcorrmin',nbv,nbs);
        if isempty(tirages)
            tirages=lhsdesign(prod(nbs(:)),nbv,'criterion','correlation','iterations',nb_iter);
            save(fich,'tirages');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Latin Hypercube Sampling (fonction Matlab) maximin (cf help)
    case 'LHSD_MAXMIN'
        tirages=lhsdesign(prod(nbs(:)),nbv,'criterion','maximin','iterations',nb_iter);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % LHS avec stockage des donnees
    case 'LHSD_MAXMIN_manu'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('lhsdmaxmin',nbv,nbs);
        if isempty(tirages)
            tirages=lhsdesign(prod(nbs(:)),nbv,'criterion','maximin','iterations',nb_iter);
            save(fich,'tirages');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Latin Hypercube Sampling (fonction Matlab) Non-smooth (cf help)
    case 'LHSD_NS'
        tirages=lhsdesign(prod(nbs(:)),nbv,'smooth','off','iterations',nb_iter);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % LHS avec stockage des donnees
    case 'LHSD_NS_manu'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('lhsdns',nbv,nbs);
        if isempty(tirages)
            tirages=lhsdesign(prod(nbs(:)),nbv,'smooth','off','iterations',nb_iter);
            save(fich,'tirages');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Latin Hypercube Sampling (a loi uniforme)
    case 'LHS'
        tirages=lhsu(Xmin_def,Xmax_def,prod(nbs(:)));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % LHS avec stockage des donnees
    case 'LHS_manu'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('lhsu',nbv,nbs);
        if isempty(tirages)
            tirages=lhsu(Xmin_def,Xmax_def,prod(nbs(:)));
            save(fich,'tirages');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Improved Hypercube Sampling
    case 'IHS'
        tirages=ihs(nbv,nbs,5,17);
        tirages=tirages./nbs;
        tirages=tirages';
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'IHS_manu'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('ihs',nbv,nbs);
        if isempty(tirages)
            tirages=ihs(nbv,nbs,5,17);
            tirages=tirages./nbs;
            tirages=tirages';
            save(fich,'tirages');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Latin Hypercube Sampling (a loi uniforme) par minimisation somme
        % distance interpoints
    case 'LHS_O1'
        tir_tmp=cell(1,nb_gene);
        sc=zeros(1,nb_gene);
        %on genere nb_gene tirages
        for ii=1:nb_gene
            tir_tmp{ii}=lhsu(Xmin_def,Xmax_def,prod(nbs(:)));
            %calcul score
            uni=score_doe(tir_tmp{ii});
            sc(ii)=uni.sum_dist;
        end
        [~,IX]=min(sc);
        tirages=tir_tmp{IX};
        clear tir_tmp;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % LHS_O1 avec stockage des donnees
    case 'LHS_O1_manu'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('lhs_o1',nbv,nbs);
        if isempty(tirages)
            tir_tmp=cell(1,nb_gene);
            sc=zeros(1,nb_gene);
            %on genere nb_gene tirages
            for ii=1:nb_gene
                tir_tmp{ii}=lhsu(Xmin_def,Xmax_def,prod(nbs(:)));
                %calcul score
                uni=score_doe(tir_tmp{ii});
                sc(ii)=uni.sum_dist;
            end
            [~,IX]=min(sc);
            tirages=tir_tmp{IX};
            clear tir_tmp
            save(fich,'tirages');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'IHS_R_manu_enrich'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('ihsre',nbv,nbs);
        if isempty(tirages)
            t_init=ihs_R(Xmin_def,Xmax_def,doe.nbs_min); % on initialise le tirage
            [tirages,~]=ihs_R(Xmin_def,Xmax_def,doe.nbs_min,t_init,doe.nbs_max);
            save(fich,'tirages');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'LHS_R_manu_enrich'
        %recuperation tirage si dispo
        [tirages,fich]=test_tir('lhsre',nbv,nbs);
        if isempty(tirages)
            t_init=lhsu_R(Xmin_def,Xmax_def,doe.nbs_min); % on initialise le tirage
            [tirages,~]=lhsu_R(Xmin_def,Xmax_def,doe.nbs_min,t_init,doe.nbs_max);
            save(fich,'tirages');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % tirages aleatoires
    case 'rand'
        tirages=rand(prod(nbs(:)),nbv);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %tirages definis manuellement
    case 'perso'
        tirages=doe.manu;
        tir_perso=true;
        disp('/!\ Echantillonnage manuel (cf. conf_doe.m)');
    otherwise
        error('le type de tirage nest pas defini\n');
        tir_ok=false;
end

if tir_ok
    if ~tir_perso
        % on corrige le tirage pour obtenir le bon espace
        tirages=tirages.*repmat(Xmax(:)'-Xmin(:)',prod(nbs(:)),1)+repmat(Xmin(:)',prod(nbs(:)),1);
    end
    %Tri des tirages (par rapport a une variable
    if isfield(doe,'tri')&&doe.tri>0
        if doe.tri<=size(tirages,1)
            [~,ind]=sort(tirages(:,doe.tri));
            tirages=tirages(ind,:);
        else
            fprintf('###############################################################\n');
            fprintf('## ##mauvais parametre de tri des tirages (tri desactive) ## ##\n');
            fprintf('###############################################################\n');
        end
    end
    
    
    %affichage tirages
    aff_doe(tirages,doe)
else
    tirages=[];
end

mesu_time(tMesu,tInit);
fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
end


%fonction de test d'existence d'un tirages et recuperation
function [tirages,fich]=test_tir(nom_fich,nbv,nbs)

%on verifie si le dossier de stockage existe (si non on le cree)
if exist('TIR_MANU','dir')~=7
    unix('mkdir TIR_MANU');
end

%on verifie si le tirages existe deja (si oui on le charge/si non on le
%genere et le sauvegarde)
fi=['TIR_MANU/' nom_fich '_man_' num2str(nbv) '_'  num2str(nbs)];
fich=[fi '.mat'];
if exist(fich,'file')==2
    st=load(fich);
    tirages=st.tirages;
else
    fprintf('Tirage inexistant \n');
    tirages=[];
end
end