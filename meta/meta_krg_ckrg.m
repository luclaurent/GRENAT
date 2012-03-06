%% fonction de construction des métamodèles de Krigeage et de Cokrigeage
%% L. LAURENT -- 12/12/2011 -- laurent@lmt.ens-cachan.fr

function [ret]=meta_krg_ckrg(tirages,eval,grad,meta)

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

%test présence des gradients
pres_grad=~isempty(grad);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Normalisation
if meta.norm
    disp('Normalisation');
    %normalisation des donnees
    [evaln,infos_e]=norm_denorm(eval,'norm');
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
    std_e=[];
    std_t=[];
    moy_e=[];
    moy_t=[];
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
%evaluations et gradients aux points échantillonnés
y=evaln;
if pres_grad
    tmp=gradn';
    der=tmp(:);
    y=vertcat(y,der);    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%creation matrice de conception
%(regression polynomiale)
%autre fonction de calcul des regresseur reg_poly0,1 ou 2
fct=['mono_' num2str(meta.deg,'%02i') '_' num2str(nb_var,'%03i')];

%/!\ en le cokrigeage universel n'est pas opérationnel
%if pres_grad&&meta.deg~=0
%   meta.deg=0;nb_termes=1;
%   fprintf('Le Cokrigeage Universel n''est pas opérationnel (on construit un Cokrigeage Ordinaire)\n')
%end

if ~pres_grad
    fc=feval(fct,tiragesn);
else
    [Reg,nb_termes,DReg,~]=feval(fct,tiragesn);
    %initialisation matrice des regresseurs
    fc=zeros((nb_var+1)*nb_val,nb_termes);
    %chargement regresseur (evaluation de monomes)
    fc(1:nb_val,:)=Reg;
    %chargement des dérivées des regresseurs (evaluation des dérivées des monomes)
    if iscell(DReg)
        tmp=horzcat(DReg{:})';
        tmp=reshape(tmp,nb_termes,[])';
    else
        tmp=DReg';
        tmp=tmp(:);
    end
    
    fc(nb_val+1:end,:)=tmp;
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
ret.build.fc=fc;
ret.build.fct=fc';
ret.build.y=y;
ret.build.fct_reg=fct;
ret.build.corr=meta.corr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calcul de la log-vraisemblance dans le cas  de l'estimation des parametres
%(si on saouhaite avoir les valeurs de la log-vraisemblance en fonction des
%paramètres)
if meta.para.estim&&meta.para.aff_estim
    val_para=linspace(meta.para.min,meta.para.max,30);
    %dans le cas ou on considere de l'anisotropie (et si on a 2
    %variable de conception)
    if meta.para.aniso&&nb_var==2
        %on genere la grille d'étude
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
   meta.para.val=para_estim.val;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%construction des blocs de krigeage finaux tenant compte des longueurs de
%corrélation obtenues par minimisation
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
fprintf('\nExecution construction %s: %6.4d s\n',txt,tps_stop-tps_start);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Validation croisee
%%%%%Calcul des differentes erreurs
if meta.cv
    [ret.cv]=cross_validate_krg_ckrg(ret,meta);
    
    tps_cv=toc;
    fprintf('Execution validation croisee %s: %6.4d s\n\n',txt,tps_cv-tps_stop);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

