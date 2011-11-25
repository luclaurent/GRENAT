%%% Fonction assurant l'evaluation du metamodele 'Shepard Weighting Functions'
%% L. LAURENT -- 23/11/2011 -- laurent@lmt.ens-cachan.fr

function [Z,GZ]=eval_swf(U,swf)

%calcul ou non des gradients (en fonction du nombre de variables de sortie)
if nargout>=2
    grad=true;
else
    grad=false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X=U(:)';    %correction (changement type d'element)
dim_x=size(X,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation
if swf.norm.on
    infos.moy=swf.norm.moy_tirages;
    infos.std=swf.norm.std_tirages;
    X=norm_denorm(X,'norm',infos);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calcul des fonctions de ponderation au point considere
if grad
    [W,Wm,dW,dWm]=fct_swf(X,swf.tirages,swf.para);
else
    [W,Wm]=fct_swf(X,swf.tirages,swf.para);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evaluation du metamodele et des derivees
Z=Wm'*swf.eval;
if grad
    GZ=dWm'*swf.eval;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%denormalisation
if swf.norm.on
    infos.moy=swf.norm.moy_eval;
    infos.std=swf.norm.std_eval;
    Z=norm_denorm(Z,'denorm',infos);
    if grad
        infos.std_e=swf.norm.std_eval;
        infos.std_t=swf.norm.std_tirages;
        GZ=norm_denorm_g(GZ','denorm',infos); clear infos
        GZ=GZ';
    end
end
