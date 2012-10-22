%% Procedure de calcul des erreurs par LOO
%% L. LAURENt -- 22/10/2012 -- laurent@lmt.ens-cahcan.fr

function [ret]=calc_err_loo(Zref,Zap,GZref,GZap,nb_val,nb_var,LOO_norm)

%test de presence des gradients de reference
pres_grad=true;
if isempty(GZref)
    pres_grad=false;
end


%ecart reponses
diff=Zap-Zref;
if pres_grad
    %ecart gradients
    diffg=GZap-GZref;
end
%ecart reponses (norme au choix)
switch LOO_norm
    case 'L1'
        diffc=abs(diff);
    case 'L2'
        diffc=diff.^2;
    case 'Linf'
        diffc=max(diff(:));
end
%critere perso
somm=0.5*(Zap+Zref);
ret.errp=1/nb_val*sum(abs(diff)./somm);
%PRESS
ret.press=sum(diffc);
%biais moyen
ret.bm=1/nb_val*sum(diff);
if pres_grad
    %ecart gradients (norme au choix)
    switch LOO_norm
        case 'L1'
            diffgc=abs(diffg);
        case 'L2'
            diffgc=diff.^2;
        case 'Linf'
            diffgc=max(diffg);
    end
    %moyenne ecart reponses, gradients et mixte au carres
    ret.eloor=1/nb_val*sum(diffc);
    ret.eloog=1/(nb_val*nb_var)*sum(diffgc(:));
    ret.eloot=1/(nb_val*(1+nb_var))*(sum(diffc)+sum(diffgc(:)));
else
    %moyenne ecart reponses
    ret.eloor=1/nb_val*sum(diffc);
    ret.eloot=cv.perso.eloor;
end
%critere d'adequation (SCVR Keane 2005/Jones 1998)
ret.scvr=diff./cv_var;
ret.scvr_min=min(cv.perso.scvr(:));
ret.scvr_max=max(cv.perso.scvr(:));
ret.scvr_mean=mean(cv.perso.scvr(:));
%critere d'adequation (ATTENTION: a la norme!!!>> diff au carre)
diffa=diffc./cv_var;
ret.adequ=1/nb_val*sum(diffa);
