%%fonction permettant de construire un metamodele Ã  l'aide de fonctions a 
%base radiale
% RBF: sans gradient
% HBRBF: avec gradients
%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 15/03/2010 modif le 12/04/2010 puis le 15/01/2012

function ret=meta_rbf(tirages,eval,grad,meta)


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
    rbf.norm.moy_eval=infos_e.moy;
    rbf.norm.std_eval=infos_e.std;
    rbf.norm.moy_tirages=infos_t.moy;
    rbf.norm.std_tirages=infos_t.std;
    rbf.norm.on=true;
    clear infos_e infos_t
else
    rbf.norm.on=false;
    std_e=[];
    std_t=[];
    moy_e=[];
    moy_t=[];
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
%evaluations et gradients aux points échantillonnés
y=evaln;
if pres_grad
    tmp=gradn';
    der=tmp(:);
    y=vertcat(y,der);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%construction de la matrice de Gram
if pres_grad
else
    KK=zeros(nb_val);
    for ii=1:nb_val
        for jj=1:nb_val
            KK(ii,jj)=feval(meta.fct,tiragesn(jj,:)-tiragesn(ii,:),meta.para.val);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Détermination des coefficients
w=KK\y;

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
ret.norm=rbf.norm;
ret.build.KK=KK;
ret.build.w=w;
ret.build.y=y;
ret.build.fct=meta.fct;
ret.build.para=meta.para;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tps_stop=toc;
ret.tps=tps_stop-tps_start;
if pres_grad;txt='HBRBF';else txt='RBF';end
fprintf('\nExecution construction %s: %6.4d s\n',txt,tps_stop-tps_start);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Validation croisee
%%%%%Calcul des differentes erreurs
if meta.cv
    [ret.cv]=cross_validate_rbf(ret,meta);
    
    tps_cv=toc;
    fprintf('Execution validation croisee %s: %6.4d s\n\n',txt,tps_cv-tps_stop);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


