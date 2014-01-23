%%fonction de base radiale exponentielle carr�e (RBF)
%%L. LAURENT -- 18/01/2012 -- luc.laurent@ens-cachan.fr

%Rasmussen 2006 p. 83

function [rf,drf,ddrf]=corr_sexp_old(xx,long)

%verification de la dimension de la longueur de correlation
lt=size(long);
%nombre de points a� evaluer
pt_eval=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);

if lt(1)*lt(2)==1
    %long est un reel, alors on en fait une matrice de la dimension de xx
    long = repmat(long,pt_eval,nb_comp);
elseif lt(1)*lt(2)==nb_comp
    long = repmat(long,pt_eval,1);    
elseif lt(1)*lt(2)~=nb_comp
    error('mauvaise dimension de la longueur de correlation');
end


%calcul de la valeur de la fonction au point xx
td=-xx.^2./(2*long.^2);
ev=exp(sum(td,2));

if nargout==1
    rf=ev;
elseif nargout==2
    rf=ev;
    drf=-xx./long.^2.*repmat(ev,1,nb_comp);
elseif nargout==3
    rf=ev;
    drf=-xx./long.^2.*repmat(ev,1,nb_comp);   
    
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
                    ddrf(mm,ll)=ev/long(1,mm)^4*(xx(mm)^2-long(1,mm)^2);
                else
                    ddrf(mm,ll)=ev/(long(1,mm)^2*long(1,ll)^2)*xx(ll)*xx(mm);
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
                    ddrf(mm,ll,:)=ev./long(1,mm)^4.*(xx(:,mm).^2-long(1,mm)^2);
                else
                    ddrf(mm,ll,:)=ev./(long(1,mm)^2*long(1,ll)^2).*xx(:,ll).*xx(:,mm);
                end
           end
        end
    end
else
    error('Mauvais argument de sortie de la fonction corr_sexp');
end