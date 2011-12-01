%%% Fonction assurant la préparation des données pour le metamodele 'Shepard Weighting Functions'
%% L. LAURENT -- 23/11/2011 -- laurent@lmt.ens-cachan.fr

function swf=meta_swf(tirages,eval,grad,meta)

global aff

%initialisation compteur temps
tic;tps_start=toc;

%nombre d'evalutions
nbs=size(eval,1);
%dimension du pb (nb de variables de conception)
nbv=size(tirages,2);

%Presence des gradients
pec_grad=~isempty(grad);

%Normalisation
if meta.norm
    fprintf('Normalisation\n');
    %normalisation des données
    [evaln,infos_e]=norm_denorm(eval,'norm');
    [tiragesn,infos_t]=norm_denorm(tirages,'norm');
    infos.std_e=infos_e.std;std_e=infos_e.std;
    infos.moy_e=infos_e.moy;moy_e=infos_e.moy;
    infos.std_t=infos_t.std;std_t=infos_t.std;
    infos.moy_t=infos_t.moy;moy_t=infos_t.moy;
    if pec_grad
        gradn=norm_denorm_g(grad,'norm',infos);
    end
    %sauvegarde des calculs
    swf.norm.moy_eval=infos_e.moy;
    swf.norm.std_eval=infos_e.std;
    swf.norm.moy_tirages=infos_t.moy;
    swf.norm.std_tirages=infos_t.std;
    swf.norm.on=true;
    clear infos_e infos_t
    clear infos
    swf.norm.on=true;
else
    swf.norm.on=false;
    evaln=eval;
    tiragesn=tirages;
    gradn=grad;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%creation vecteur des tirages
swf.tirages=tiragesn;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%creation vecteur des evaluations et de gradients
swf.eval=evaln;
swf.grad=gradn;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sauvegarde des données
swf.nbs=nbs;
swf.nbv=nbv;
swf.para=meta.swf_para;	%rayon d'influence des fonctions de ponderation
if pec_grad
    tt=tirages';
    stock=zeros(nbs*(nbv+1),1);
    ind=1:(nbs*(nbv+1));
    
    rech=mod(ind,nbv+1);
    IX=find(rech==1);
    IXX=find(rech~=1);
    
    stock(IXX)=tt(:);
    swf.tir_colon=stock;    %conditionnement des tirages pour construction avec gradients
    data=stock;
    data(IX)=evaln;
    data(IXX)=gradn;
    swf.F=data;             %conditionnement des �valuations et gradients 
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fittage des parametres par CV (LOO)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tps_stop=toc;
swf.tps=tps_stop-tps_start;
fprintf('\nExecution preparation SWF: %6.4d s\n',tps_stop-tps_start);

end