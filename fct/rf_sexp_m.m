%%fonction de base radiale exponentielle carree
%%L. LAURENT -- 18/01/2012 -- luc.laurent@ens-cachan.fr
%revision du 13/11/2012
%modification parametre le 19/12/2012


%Rasmussen 2006 p. 83

function [rf,drf,ddrf]=rf_sexp_m(xx,long)

%verification de la dimension de la longueur de rfelation
lt=size(long);
%nombre de points a evaluer
nb_pt=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);
%nombre de sorties
nb_out=nargout;

if lt(1)*lt(2)==1
    %long est un reel, alors on en fait une matrice de la dimension de xx
    long = long*ones(nb_pt,nb_comp);
elseif lt(1)*lt(2)==nb_comp
    long = long(ones(nb_pt,1),:);
elseif lt(1)*lt(2)~=nb_comp
    error('mauvaise dimension de la longueur de d''influence');
end


%calcul de la valeur de la fonction au point xx
td=-xx.^2.*long;
ev=exp(sum(td,2));

if nb_out==1
    rf=ev;
elseif nb_out==2
    rf=ev;
    drf=-2*xx.*long.*ev(:,ones(1,nb_comp));
elseif nb_out==3
    rf=ev;
    drf=-2*xx.*long.^2.*ev(:,ones(1,nb_comp));   
    
    %calcul des derivees secondes    
    
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    %si on ne demande le calcul des derivees secondes en un seul point, on
    %les stocke dans une matrice 
    if nb_pt==1
        ddrf=zeros(nb_comp);
        for ll=1:nb_comp
           for mm=1:nb_comp
                if(mm==ll)
                    ddrf(mm,ll)=ev*4*long(1,mm)^2*(xx(mm)^2-1/(2*long(1,mm)));
                else
                    ddrf(mm,ll)=ev*4*long(1,mm)*long(1,ll)*xx(ll)*xx(mm);
                end
           end
        end
       
    %si on demande le calcul des derivees secondes en plusieurs point, on
    %les stocke dans un vecteur de matrices
    else
        ddrf=zeros(nb_comp,nb_comp,nb_pt);
        for ll=1:nb_comp
           for mm=1:nb_comp
                if(mm==ll)                    
                    ddrf(mm,ll,:)=4*ev.*long(1,mm)^2.*(xx(:,mm).^2-1/(2*long(1,mm)));
                else
                    ddrf(mm,ll,:)=4*ev.*long(1,mm)*long(1,ll).*xx(:,ll).*xx(:,mm);
                end
           end
        end
    end
else
    error('Mauvais argument de sortie de la fonction rf_sexp');
end