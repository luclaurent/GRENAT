%%fonction de base radiale thin plate splines(RBF)
%%L. LAURENT -- 17/01/2012 -- laurent@lmt.ens-cachan.fr

function [corr,dcorr,ddcorr]=rf_thin_plate_splines(xx,long)

%Cette fonction est non paramétrique

para=2;

%nombre de points a evaluer
pt_eval=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);

%calcul de la valeur de la fonction au point xx
td=xx.^2;
e=sqrt(sum(td,2));
le=log(e);
ev=e.^para.*le;

if nargout==1
    corr=ev;
elseif nargout==2
    corr=ev;
    dcorr=xx./repmat(ev,1,nb_comp).^(para-2).*(1+para*repmat(le,1,nb_comp));
elseif nargout==3
    corr=ev;
    dcorr=xx./repmat(ev,1,nb_comp).^(para-2).*(1+para*repmat(le,1,nb_comp));
  
    
    %calcul des derivees secondes    
    
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    %si on ne demande le calcul des derivees secondes en un seul point, on
    %les stocke dans une matrice 
    if pt_eval==1
        ddcorr=zeros(nb_comp);
        for ll=1:nb_comp
           for mm=1:nb_comp
                if(mm==ll)
                    ddcorr(mm,ll)=ev^(para-2)*(1+para*le)+2*(para-1)*xx(mm)^2*...
                        ev^(para-4)+xx(mm)*para*(para-2)*ev^(para-4)*le;
                else
                    ddcorr(mm,ll)=xx(ll)*xx(mm)*ev^(para-4)*...
                        (2*para+para*le*(para-2)-2);
                end
           end
        end
       
    %si on demande le calcul des derivees secondes en plusieurs point, on
    %les stocke dans un vecteur de matrices
    else
        ddcorr=zeros(nb_comp,nb_comp,pt_eval);
        for ll=1:nb_comp
           for mm=1:nb_comp
                if(mm==ll)                    
                    ddcorr(mm,ll,:)=ev.^(para-2).*(1+para*le)+2*(para-1)*xx(:,mm).^2.*...
                        ev.^(para-4)+xx(mm)*para*(para-2).*ev.^(para-4).*le;
                else
                    ddcorr(mm,ll,:)=xx(:,ll).*xx(:,mm).*ev.^(para-4).*...
                        (2*para+para*le*(para-2)-2);
                end
           end
        end
        if nb_comp==1
            ddcorr=vertcat(ddcorr(:));
        end

    end
   
    
else
    error('Mauvais argument de sortie de la fonction corr_gauss');
end