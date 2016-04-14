%%fonction permettant de construire un metamodele à l'aide de fonctions a
%base radiale
% RBF: sans gradient
% HBRBF: avec gradients
%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 15/03/2010 modif le 12/04/2010 puis le 15/01/2012

function ret=meta_rbf(tirages,eval,grad,meta,manq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Affichage des informations de construction
fprintf(' >> Construction : ');
if ~isempty(grad);fprintf('GRBF \n');else fprintf('RBF \n');end
fprintf('>> Fonction de base radiale: %s\n',meta.rbf);
fprintf('>>> Normalisation: ');if meta.norm; fprintf('Oui\n');else fprintf('Non\n');end
fprintf('>>> CV: ');if meta.cv; fprintf('Oui\n');else fprintf('Non\n');end
fprintf('>>> Calcul tous criteres CV: ');if meta.cv_full; fprintf('Oui\n');else fprintf('Non\n');end
fprintf('>> Affichage CV: ');if meta.cv_aff; fprintf('Oui\n');else fprintf('Non\n');end

fprintf('>>> Estimation parametre: ');if meta.para.estim; fprintf('Oui\n');else fprintf('Non\n');end
if meta.para.estim
    fprintf('>> Algo estimation: %s\n',meta.para.method);
    fprintf('>> Bornes recherche: [%d , %d]\n',meta.para.l_min,meta.para.l_max);
    switch meta.rbf
        case {'rf_expg','rf_expgg'}
            fprintf('>> Bornes recherche puissance: [%d , %d]\n',meta.para.p_min,meta.para.p_max);
    end
    fprintf('>> Anisotropie: ');if meta.para.aniso; fprintf('Oui\n');else fprintf('Non\n');end
    fprintf('>> Affichage estimation console: ');if meta.para.aff_iter_cmd; fprintf('Oui\n');else fprintf('Non\n');end
    fprintf('>> Affichage estimation graphique: ');if meta.para.aff_iter_graph; fprintf('Oui\n');else fprintf('Non\n');end
else
    fprintf('>> Valeur parametre: %d\n',meta.para.l_val);
    switch meta.rbf
        case {'rf_expg','rf_expgg'}
            fprintf('>> Bornes recherche puissance: [%d , %d]\n',meta.para.p_val);
    end
end
fprintf('>> Critere enrichissement actif:');
if meta.enrich.on;
    fprintf('%s\n','Oui');
    fprintf('>> Ponderation WEI: ')
    fprintf('%d ',meta.enrich.para_wei);
    fprintf('\n')
    fprintf('>> Ponderation GEI: ')
    fprintf('%d ',meta.enrich.para_gei);
    fprintf('\n')
    fprintf('>> Ponderation LCB: %d\n',meta.enrich.para_lcb);
else
    fprintf('%s\n','non');
end
fprintf('\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%chargement variables globales
global aff

%initialisation tempo
tic;
tps_start=toc;

%initialisation des variables
%nombre d'evalutions
nb_val=size(eval,1);
%dimension du pb (nb de variables de conception)
nb_var=size(tirages,2);

%test presence des gradients
pres_grad=~isempty(grad);
%test donnees manquantes
if nargin==5
    manq_eval=manq.eval.on;
    manq_grad=manq.grad.on;
    pres_grad=(~manq.grad.all&&manq.grad.on)||(pres_grad&&~manq.grad.on);
else
    manq.eval.on=false;
    manq.grad.on=false;
    manq_eval=manq.eval.on;
    manq_grad=manq.grad.on;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Normalisation
if meta.norm
    disp('Normalisation');
    %normalisation des donnees
    [evaln,infos_e]=norm_denorm(eval,'norm',manq);
    [tiragesn,infos_t]=norm_denorm(tirages,'norm');
    std_e=infos_e.std;moy_e=infos_e.moy;
    std_t=infos_t.std;moy_t=infos_t.moy;
    
    %normalisation des gradients
    if pres_grad
        infos.std_e=infos_e.std;infos.moy_e=infos_e.moy;
        infos.std_t=infos_t.std;infos.moy_t=infos_t.moy;
        gradn=norm_denorm_g(grad,'norm',infos); clear infos
    else
        gradn=[];
    end
    
    %sauvegarde des calculs
    rbf.norm.moy_eval=infos_e.moy;
    rbf.norm.std_eval=infos_e.std;
    rbf.norm.moy_tirages=infos_t.moy;
    rbf.norm.std_tirages=infos_t.std;
    rbf.norm.on=true;
    clear infos_e infos_t
else
    rbf.norm.on=false;
    rbf.norm.moy_eval=[];
    rbf.norm.std_eval=[];
    rbf.norm.moy_tirages=[];
    rbf.norm.std_tirages=[];
    rbf.norm.on=false;
    evaln=eval;
    tiragesn=tirages;
    if pres_grad
        gradn=grad;
    else
        gradn=[];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%evaluations et gradients aux points echantillonnes
y=evaln;
%suppression reponse(s) manquantes
if manq_eval
    y=y(manq.eval.ix_dispo);
end
if pres_grad
    tmp=gradn';
    der=tmp(:);
    %supression gradient(s) manquant(s)
    if manq_grad
        der=der(manq.grad.ixt_dispo_line);
    end
    y=vertcat(y,der);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% construction systeme d'indices pour la construction de la matrice de
% krigeage/cokrigeage
if pres_grad
    
    taille_matRc=(nb_val^2+nb_val)/2;
    taille_matRa=nb_var*(nb_val^2+nb_val)/2;
    taille_matRi=nb_var^2*(nb_val^2+nb_val)/2;
    ind_matrix=zeros(taille_matRc,1);
    ind_matrixA=zeros(taille_matRa,1);
    ind_matrixAb=zeros(taille_matRa,1);
    ind_matrixI=zeros(taille_matRi,1);
    ind_dev=zeros(taille_matRa,1);
    ind_pts=zeros(taille_matRc,2);
    
    liste_tmp=zeros(taille_matRc,nb_var);
    liste_tmp(:)=1:taille_matRc*nb_var;
    
    ite=0;
    iteA=0;
    iteAb=0;
    pres=0;
    %table indices pour les inter-distances (1), les reponses (1) et les
    %derivees 1ere (2)
    for ii=1:nb_val
        
        ite=ite(end)+(1:(nb_val-ii+1));
        ind_matrix(ite)=(nb_val+1)*ii-nb_val:ii*nb_val;
        ind_pts(ite,:)=[ii(ones(nb_val-ii+1,1)) (ii:nb_val)'];        
        iteAb=iteAb(end)+(1:((nb_val-ii+1)*nb_var));
        
        debb=(ii-1)*nb_var*nb_val+ii;
        finb=nb_val^2*nb_var-(nb_val-ii);
        lib=debb:nb_val:finb;
        
        ind_matrixAb(iteAb)=lib;

        for jj=1:nb_var
            iteA=iteA(end)+(1:(nb_val-ii+1));
            decal=(ii-1);
            deb=pres+decal;
            li=deb + (1:(nb_val-ii+1));
            ind_matrixA(iteA)=li;
            pres=li(end);
            liste_tmpB=reshape(liste_tmp',[],1);
            ind_dev(iteA)=liste_tmp(ite,jj);
            ind_devb=liste_tmpB; 
        end
    end
    %table indices derivees secondes
    a=zeros(nb_val*nb_var,nb_var);
    decal=0;
    precI=0;
    iteI=0;
    for ii=1:nb_val
        li=1:nb_val*nb_var^2;
        a(:)=decal+li;
        decal=a(end);
        b=a';
        
        iteI=precI+(1:(nb_var^2*(nb_val-(ii-1))));
        
        debb=(ii-1)*nb_var^2+1;
        finb=nb_var^2*nb_val;
        iteb=debb:finb;
        ind_matrixI(iteI)=b(iteb);
        precI=iteI(end);
    end
else
    %table indices pour les inter-distances (1), les reponses (1)
    bmax=nb_val-1;
    ind_matrix=zeros(nb_val*(nb_val-1)/2,1);
    ind_pts=zeros(nb_val*(nb_val-1)/2,2);
    ite=0;
    for ii=1:bmax
        ite=ite(end)+(1:(nb_val-ii));
        ind_matrix(ite)=(nb_val+1)*ii-nb_val+1:ii*nb_val;
        ind_pts(ite,:)=[ii(ones(nb_val-ii,1)) (ii+1:nb_val)'];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calcul distances inter-sites
dist=tiragesn(ind_pts(:,1),:)-tiragesn(ind_pts(:,2),:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des grandeurs
ret.in.tirages=tirages;
ret.in.tiragesn=tiragesn;
ret.in.dist=dist;
ret.in.eval=eval;
ret.in.evaln=evaln;
ret.in.pres_grad=pres_grad;
ret.in.grad=grad;
ret.in.gradn=gradn;
ret.in.nb_var=nb_var;
ret.in.nb_val=nb_val;
ret.ind.matrix=ind_matrix;
ret.ind.pts=ind_pts;
if pres_grad
    ret.ind.matrixA=ind_matrixA;
    ret.ind.matrixAb=ind_matrixAb;
    ret.ind.matrixI=ind_matrixI;
    ret.ind.dev=ind_dev;
    ret.ind.devb=ind_devb;
end
ret.build.y=y;
ret.norm=rbf.norm;
ret.manq=manq;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calcul de MSE par Cross-Validation
%arret affichage CV si c'est le cas et activation CV si ca n'est pas le cas
cv_old=meta.cv;
aff_cv_old=meta.cv_aff;
meta.cv_aff=false;

if meta.para.estim&&meta.para.aff_estim
    val_para=linspace(meta.para.l_min,meta.para.l_max,gene_nbele(nb_var));
    %dans le cas ou on considere de l'anisotropie (et si on a 2
    %variable de conception)
    if meta.para.aniso&&nb_var==2
        %on genere la grille d'etude
        [val_X,val_Y]=meshgrid(val_para,val_para);
        %initialisation matrice de stockage des valeurs de la
        %log-vraisemblance
        val_msep=zeros(size(val_X));
        %si affichage dispo
        if usejava('desktop');h = waitbar(0,'Evaluation critere .... ');end
        for itli=1:numel(val_X)
            
            %calcul de la log-vraisemblance et stockage
            val_msep(itli)=bloc_rbf(ret,meta,[val_X(itli) val_Y(itli)]);
            %affichage barre attente
            if usejava('desktop')&&exist('h','var')
                avance=(itli-1)/numel(val_X);
                aff_av=avance*100;
                mess=['Eval. en cours ' num2str(aff_av,3) '% ' num2str(itli) '/' num2str(numel(val_X)) ];
                waitbar(avance,h,mess);
            end
        end
        close(h)
        %trace log-vraisemblance
        figure;
        [C,h]=contourf(val_X,val_Y,val_msep);
        text_handle = clabel(C,h);
        set(text_handle,'BackgroundColor',[1 1 .6],...
            'Edgecolor',[.7 .7 .7])
        set(h,'LineWidth',2)
        %stockage de la figure au format LaTeX/TikZ
        if meta.save
            matlab2tikz([aff.doss '/logli.tex'])
        end
        
    elseif ~meta.para.aniso||nb_var==1
        %initialisation matrice de stockage des valeurs de la
        %log-vraisemblance
        val_msep=zeros(1,length(val_para));
        rippa_bomp=val_msep;
        cv_moi=val_msep;
        %si affichage dispo
        if usejava('desktop');h = waitbar(0,'Evaluation critere .... ');end
        for itli=1:length(val_para)
            val_para(itli)
            %calcul de la log-vraisemblance et stockage
            [~,build_rbf]=bloc_rbf(ret,meta,val_para(itli),'etud');
            rippa_bomp(itli)=build_rbf.cv.and.eloot;
            cv_moi(itli)=build_rbf.cv.then.eloot;
            %affichage barre attente
            if usejava('desktop')&&exist('h','var')
                avance=(itli-1)/length(val_para);
                aff_av=avance*100;
                mess=['Eval. en cours ' num2str(aff_av,3) '% ' num2str(itli) '/' num2str(numel(val_para)) ];
                waitbar(avance,h,mess);
            end
        end
        close(h)
        
        %stockage mse dans un fichier .dat
        if meta.save
            ss=[val_para' val_msep'];
            save([aff.doss '/logli.dat'],'ss','-ascii');
        end
        
        %trace log-vraisemblance
        figure;
        semilogy(val_para,rippa_bomp,'r');
        hold on
        semilogy(val_para,cv_moi,'k');
        legend('Rippa (Bompard)','Moi');
        title('CV');
        
        %         semilogy(val_para,val_msep);
        %         title('Evolution de MSE (CV)');
        
    end
    
    %stocke les courbes (si actif)
    if aff.save&&(nb_val<=2)
        fich=save_aff('fig_mse_cv',aff.doss);
        if aff.tex
            fid=fopen([aff.doss '/fig.tex'],'a+');
            fprintf(fid,'\\figcen{%2.1f}{../%s}{%s}{%s}\n',0.7,fich,'Vraisemblance',fich);
            %fprintf(fid,'\\verb{%s}\n',fich);
            fclose(fid);
        end
    end
end
%rechargement config initiale si c'etait le cas avant la phase d'estimation
meta.cv_aff=aff_cv_old;
meta.cv=cv_old;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Construction des differents elements avec ou sans estimation des
%%parametres sinon on propose une/des valeur(s) des parametres a partir des
%%proposition de Hardy/Franke
if meta.para.estim
    para_estim=estim_para_rbf(ret,meta);
    ret.build.para_estim=para_estim;
    meta.para.l_val=para_estim.l_val;
    meta.para.val=para_estim.l_val;
    if isfield(para_estim,'p_val')
        meta.para.p_val=para_estim.p_val;
        meta.para.val=[meta.para.val meta.para.p_val];
    end
else
    meta.para.l_val=calc_para_rbf(tiragesn,meta);
    switch meta.rbf
        case {'rf_expg','rf_expgg'}
            meta.para.val=[meta.para.l_val meta.para.p_val];
        otherwise
            meta.para.val=meta.para.l_val;
    end
    fprintf('Definition parametre (%s), val=',meta.para.type);
    fprintf(' %d',meta.para.val);
    fprintf('\n');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% construction elements finaux RBF (matrice, coefficients et CV) en tenant
% compte des parametres obtenus par minimisation
[~,block]=bloc_rbf(ret,meta);
%sauvegarde informations
tmp=mergestruct(ret.build,block.build);
ret.build=tmp;
ret.cv=block.cv;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tps_stop=toc;
ret.tps=tps_stop-tps_start;
if pres_grad;txt='GRBF';else txt='RBF';end
fprintf('\nExecution construction %s: %6.4d s\n',txt,tps_stop-tps_start);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


