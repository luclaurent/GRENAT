%% fonction de construction des metamodeles de Krigeage et de Cokrigeage
%% L. LAURENT -- 12/12/2011 -- laurent@lmt.ens-cachan.fr

function [ret]=meta_krg_ckrg(tirages,eval,grad,meta,manq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Affichage des informations de construction
fprintf(' >> Construction : ');
if ~isempty(grad);fprintf('CoKrigeage \n');else fprintf('Krigeage \n');end
fprintf('>> Deg : %i ',meta.deg);
if meta.deg==0; fprintf('(Ordinaire)\n');else fprintf('(Universel)\n');end;
fprintf('>> Fonction de correlation: %s\n',meta.corr);
fprintf('>>> CV: ');if meta.cv; fprintf('Oui\n');else fprintf('Non\n');end
fprintf('>> Affichage CV: ');if meta.cv_aff; fprintf('Oui\n');else fprintf('Non\n');end

fprintf('>>> Estimation parametre: ');if meta.para.estim; fprintf('Oui\n');else fprintf('Non\n');end
if meta.para.estim
    fprintf('>> Algo estimation: %s\n',meta.para.method);
    fprintf('>> Borne recherche: [%d , %d]\n',meta.para.min,meta.para.max);
    fprintf('>> Anisotropie: ');if meta.para.aniso; fprintf('Oui\n');else fprintf('Non\n');end
    fprintf('>> Affichage estimation console: ');if meta.para.aff_iter_cmd; fprintf('Oui\n');else fprintf('Non\n');end
    fprintf('>> Affichage estimation graphique: ');if meta.para.aff_iter_graph; fprintf('Oui\n');else fprintf('Non\n');end
else
    fprintf('>> Valeur parametre: %d\n',meta.para.l_val);
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

fprintf('\n\n')
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
manq_eval=false;
manq_grad=false;
if nargin==5
    manq_eval=manq.eval.on;
    manq_grad=manq.grad.on;
    pres_grad=(~manq.grad.all&&manq.grad.on)||(pres_grad&&~manq.grad.on);
else
    manq=[];
    manq.eval.on=false;
    manq.grad.on=false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Normalisation
if meta.norm
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
    nkrg.norm.moy_eval=infos_e.moy;
    nkrg.norm.std_eval=infos_e.std;
    nkrg.norm.moy_tirages=infos_t.moy;
    nkrg.norm.std_tirages=infos_t.std;
    nkrg.norm.on=true;
    clear infos_e infos_t
else
    nkrg.norm.on=false;
    nkrg.norm.moy_eval=[];
    nkrg.norm.std_eval=[];
    nkrg.norm.moy_tirages=[];
    nkrg.norm.std_tirages=[];
    nkrg.norm.on=false;
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
%evaluations et gradients aux points �chantillonn�s
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
%creation matrice de conception
%(regression polynomiale)
%autre fonction de calcul des regresseur reg_poly0,1 ou 2
fct_reg=['mono_' num2str(meta.deg,'%02i') '_' num2str(nb_var,'%03i')];

%/!\ en le cokrigeage universel n'est pas operationnel
%if pres_grad&&meta.deg~=0
%   meta.deg=0;nb_termes=1;
%   fprintf('Le Cokrigeage Universel n''est pas operationnel (on construit un Cokrigeage Ordinaire)\n')
%end

if ~pres_grad
    fct=feval(fct_reg,tiragesn);
    if manq_eval
        %suppression valeur(s) aux sites a reponse(s) manquante(s)
        fct=fct(manq.eval.ix_dispo,:);
    end
else
    [Reg,nb_termes,DReg,~]=feval(fct_reg,tiragesn);
    if manq_eval||manq_grad
        taille_ev=nb_val-manq.eval.nb;
        taille_gr=nb_val*nb_var-manq.grad.nb;
        taille_tot=taille_ev+taille_gr;
    else
        taille_ev=nb_val;
        taille_gr=nb_val*nb_var;
        taille_tot=taille_ev+taille_gr;
    end
    %initialisation matrice des regresseurs
    fct=zeros(taille_tot,nb_termes);
    if manq_eval
        %suppression valeur(s) aux site a reponse(s) manquante(s)
        Reg=Reg(manq.eval.ix_dispo,:);
    end
    %chargement regresseur (evaluation de monomes)
    fct(1:taille_ev,:)=Reg;
    %chargement des derivees des regresseurs (evaluation des derivees des monomes)
    if iscell(DReg)
        tmp=horzcat(DReg{:})';
        tmp=reshape(tmp,nb_termes,[])';
    else
        tmp=DReg';
        tmp=tmp(:);
    end
    
    if manq_grad
        %suppression valeur(s) aux sites a gradient(s) manquant(s)
        tmp=tmp(manq.grad.ixt_dispo_line,:);
    end
    %chargement derivees regresseur
    fct(taille_ev+1:end,:)=tmp;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des grandeurs
ret.in.tirages=tirages;
ret.in.tiragesn=tiragesn;
ret.in.eval=eval;
ret.in.evaln=evaln;
ret.in.pres_grad=pres_grad;
ret.in.grad=grad;
ret.in.gradn=gradn;
ret.in.nb_var=nb_var;
ret.in.nb_val=nb_val;
ret.norm=nkrg.norm;
ret.build.fct=fct;
ret.build.fc=fct';
ret.build.dim_fc=size(fct,2);
ret.build.y=y;
ret.build.fct_reg=fct_reg;
ret.build.corr=meta.corr;
ret.manq=manq;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calcul de la log-vraisemblance dans le cas  de l'estimation des parametres
%(si on saouhaite avoir les valeurs de la log-vraisemblance en fonction des
%parametres)
if meta.para.estim&&meta.para.aff_estim
    val_para=linspace(meta.para.min,meta.para.max,30);
    %dans le cas ou on considere de l'anisotropie (et si on a 2
    %variable de conception)
    if meta.para.aniso&&nb_var==2
        %on genere la grille d'�tude
        [val_X,val_Y]=meshgrid(val_para,val_para);
        %initialisation matrice de stockage des valeurs de la
        %log-vraisemblance
        val_lik=zeros(size(val_X));
        for itli=1:numel(val_X)
            %calcul de la log-vraisemblance et stockage
            val_lik(itli)=bloc_krg_ckrg(ret,meta,[val_X(itli) val_Y(itli)]);
            %aff_avance(itli,numel(val_X));
        end
        %trace log-vraisemblance
        figure;
        [C,h]=contourf(val_X,val_Y,val_lik);
        text_handle = clabel(C,h);
        set(text_handle,'BackgroundColor',[1 1 .6],...
            'Edgecolor',[.7 .7 .7])
        set(h,'LineWidth',2)
        %stockage de la figure au format LaTeX/TikZ
        if meta.save
            matlab2tikz([aff.doss '/logli.tex'])
        end
        
    elseif ~meta.para.aniso||nb_var==1
        %initialisation matrice de stockage des "valeurs de la
        %log-vraisemblance
        val_lik=zeros(1,length(val_para));
        for itli=1:length(val_para)
            %calcul de la log-vraisemblance et stockage
            val_lik(itli)=bloc_krg_ckrg(ret,meta,val_para(itli));
        end
        
        %stockage log-vraisemblance dans un fichier .dat
        if meta.save
            ss=[val_para' val_lik'];
            save([aff.doss '/logli.dat'],'ss','-ascii');
        end
        
        %trace log-vraisemblance
        figure;
        plot(val_para,val_lik);
        title('Evolution de la log-vraisemblance');
    end
    
    %stocke les courbes (si actif)
    if aff.save&&(nbv<=2)
        fich=save_aff('fig_likelihood',aff.doss);
        if aff.tex
            fid=fopen([aff.doss '/fig.tex'],'a+');
            fprintf(fid,'\\figcen{%2.1f}{../%s}{%s}{%s}\n',0.7,fich,'Vraisemblance',fich);
            %fprintf(fid,'\\verb{%s}\n',fich);
            fclose(fid);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Construction des differents elements avec ou sans estimation des
%%parametres
if meta.para.estim
    para_estim=estim_para_krg_ckrg(ret,meta);
    meta.para.l_val=para_estim.l_val;
    meta.para.val=para_estim.l_val;
    if isfield(para_estim,'p_val')
        meta.para.p_val=para_estim.p_val;
        meta.para.val=[meta.para.val meta.para.p_val];
    end
else
    switch meta.corr
        case {'corr_expg','corr_expgg'}
            meta.para.val=[meta.para.l_val meta.para.p_val];
        otherwise
            meta.para.val=meta.para.l_val;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%construction des blocs de krigeage finaux tenant compte des longueurs de
%correlation obtenues par minimisation
[lilog,block]=bloc_krg_ckrg(ret,meta);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sauvegarde informations
tmp=mergestruct(ret.build,block.build);
ret.build=tmp;
ret.build.lilog=lilog;
ret.build.para=meta.para;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tps_stop=toc;
ret.tps=tps_stop-tps_start;
if pres_grad;txt='CoKrigeage';else txt='Krigeage';end
fprintf('\nExecution construction %s: %6.4d s\n\n',txt,tps_stop-tps_start);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Validation croisee
%%%%%Calcul des differentes erreurs
if meta.cv
    id=tic;
    [ret.cv]=cross_validate_krg_ckrg(ret,meta);
    
    tps_cv=toc(id);
    fprintf('Execution validation croisee %s: %6.4d s\n\n',txt,tps_cv);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

