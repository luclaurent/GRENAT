%%fonction de correlation Matern (5/2)
%%L. LAURENT -- 23/01/2011 -- luc.laurent@ens-cachan.fr

function [corr,dcorr,ddcorr]=corr_matern52(xx,long)

%verification de la dimension de lalongueur de correlations
lt=length(long);
%nombre de points a  evaluer
pt_eval=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);


%La longueur de correlation est définie pour toutes les composantes de xx
if lt~=1
    error('mauvaise dimension de la longueur de corrélation');
end

%calcul de la valeur de la fonction au point xx
td=-xx/long*sqrt(3);
co=(1+sqrt(3)*xx);
ev=prod(co,2)*exp(sum(td,2));


if nargout==1
    corr=ev;
elseif nargout==2
    corr=ev;
    dcorr=-sqrt(3)/long*(1+sqrt(3)/long.*xx)*repmat(ev,1,nb_comp);
elseif nargout==3
    corr=ev;
    dcorr=-sqrt(3)/long*(1+sqrt(3)/long.*xx)*repmat(ev,1,nb_comp);  
    
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
                    ddcorr(mm,ll)=4*theta(mm)^2*xx(ll)^2*ev-2*theta(ll)*ev;
                else
                    ddcorr(mm,ll)=4*theta(mm)*theta(ll)*xx(ll)*xx(mm)*ev;
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
                    ddcorr(mm,ll,:)=4*theta(mm)^2.*xx(:,ll).^2.*ev-2*theta(ll).*ev;
                else
                    ddcorr(mm,ll,:)=4*theta(mm)*theta(ll).*xx(:,ll).*xx(:,mm).*ev;
                end
           end
        end

    end
   
    
else
    error('Mauvais argument de sortie de la fonction corr_gauss');
end