%%fonction de corrélation gauss (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function [corr,dcorr,ddcorr]=corr_gauss(xx,theta)

%vérification de la dimension de theta
lt=length(theta);
%nombre de points à évaluer
pt_eval=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);

if lt==1
    %theta est un réel, alors on en fait une matrice de la dimension de xx
    theta = repmat(theta,pt_eval,nb_comp);
elseif lt~=nb_comp
    error('mauvaise dimension de theta');
end

%calcul de la valeur de la fonction au point xx
td=-xx.^2.*theta;
ev=exp(sum(td,2));


if nargout==1
    corr=ev;
elseif nargout==2
    corr=ev;
    dcorr=-2*theta.*xx.*repmat(ev,1,nb_comp);
elseif nargout==3
    corr=ev;
    dcorr=-2*theta.*xx.*repmat(ev,1,nb_comp);   
    
    %calcul des dérivées secondes    
    
    %suivant la taille de l'évaluation demandée on stocke les dérivées
    %secondes de manières différentes
    %si on ne demande le calcul des dérivées secondes en un seul point, on
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
       
    %si on demande le calcul des dérivées secondes en plusieurs point, on
    %les stocke dans un vecteur de matrices
    else
        ddcorr=zeros(nb_comp,nb_comp,pt_eval);
        for ll=1:nb_comp
           for mm=1:nb_comp
                if(mm==ll)                    
                    ddcorr(mm,ll,:)=4*theta(mm)^2.*xx(:,ll).^2.*ev-2*theta(ll).*ev;
                else
                    ddcorr(mm,ll,:)=4*theta(mm)*theta(ll).*xx(ll).*xx(:,mm).*ev;
                end
           end
        end

    end
   
    
else
    error('Mauvais argument de sortie de la fonction corr_gauss');
end