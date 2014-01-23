%%fonction de base radiale linear splines(RBF)
%%L. LAURENT -- 17/01/2012 -- laurent@lmt.ens-cachan.fr

function [rf,drf,ddrf]=rf_lin_splines(xx,long)

%Cette fonction est non paramétrique

%nombre de points a evaluer
pt_eval=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);

%calcul de la valeur de la fonction au point xx
td=xx.^2;
ev=sqrt(sum(td,2));

if nargout==1
    rf=ev;
elseif nargout==2
    rf=ev;
    drf=xx./repmat(ev,1,nb_comp);
elseif nargout==3
    rf=ev;
    drf=xx./repmat(ev,1,nb_comp);   
    
    %calcul des derivees secondes    
    
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    %si on ne demande le calcul des derivees secondes en un seul point, on
    %les stocke dans une matrice 
    if pt_eval==1
        ddrf=zeros(nb_comp);
        for ll=1:nb_comp
           for mm=1:nb_comp
                if(mm==ll)
                    ddrf(mm,ll)=1/ev-xx(mm)^2/ev^3;
                else
                    ddrf(mm,ll)=-xx(ll)*xx(mm)/ev^3;
                end
           end
        end
       
    %si on demande le calcul des derivees secondes en plusieurs point, on
    %les stocke dans un vecteur de matrices
    else
        ddrf=zeros(nb_comp,nb_comp,pt_eval);
        for ll=1:nb_comp
           for mm=1:nb_comp
                if(mm==ll)                    
                    ddrf(mm,ll,:)=1./ev-xx(:,mm).^2./ev.^3;
                else
                    ddrf(mm,ll,:)=-xx(:,ll).*xx(:,mm)./ev.^3;
                end
           end
        end
        if nb_comp==1
            ddrf=vertcat(ddrf(:));
        end

    end
   
    
else
    error('Mauvais argument de sortie de la fonction corr_gauss');
end