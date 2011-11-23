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
    clear infos
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
%creation vecteur des evaluations
swf.eval=evaln;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sauvegarde des données
swf.nbs=nbs;
swf.nbv=nbv;
swf.para=meta.swf_para;	%rayon d'influence des fonctions de ponderation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fittage des parametres par CV (LOO)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tps_stop=toc;
krg.tps=tps_stop-tps_start;
fprintf('\nExecution preparation SWF: %6.4d s\n',tps_stop-tps_start);

end