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
if doe.aff
    para=0.1;
    if nbv==1
        figure
        plot(tirages,0.*tirages,'.o')
        xmin=esp(:,1);
        xmax=esp(:,2);
        dep=xmax-xmin;
        axis([(xmin-para*dep) (xmin+para*dep) -1 1])
    elseif nbv==2
        figure
        xmin=esp(1,1);
        xmax=esp(1,2);
        ymin=esp(1,1);
        ymax=esp(1,2);
        depx=xmax-xmin;
        depy=ymax-ymin;
        plot(tirages(:,1),tirages(:,2),'o','MarkerEdgeColor','b','MarkerFaceColor','b')
        axis([(xmin-para*depx) (xmax+para*depx) (ymin-para*depy) (ymax+para*depy)])
        line([xmin;xmin;xmax;xmax;xmax;xmax;xmax;xmin],[ymin;ymax;ymax;ymax;ymax;ymin;ymin;ymin])
    else
        figure
        it=0;
        Xmin=esp(:,1);
        Xmax=esp(:,2);
        Depx=Xmax-Xmin;
        for ii=1:nbv
            for jj=1:nbv
                it=it+1;
                if ii~=jj
                    subplot(nbv,nbv,it)
                    plot(tirages(:,ii),tirages(:,jj),'o','MarkerEdgeColor','b','MarkerFaceColor','b')
                    xmin=Xmin(ii);xmax=Xmax(ii);ymin=Xmin(jj);ymax=Xmax(jj);depx=Depx(ii);depy=Depx(jj);
                    axis([(xmin-para*depx) (xmax+para*depx) (ymin-para*depy) (ymax+para*depy)])
                    line([xmin;xmin;xmax;xmax;xmax;xmax;xmax;xmin],[ymin;ymax;ymax;ymax;ymax;ymin;ymin;ymin])
                end
            end
        end
    end
end

%% affichage infos
fprintf(' >> type de tirages: %s\n',doe.type);
end