%% Fonction: exponentielle carree
%%L. LAURENT -- 18/01/2012 -- luc.laurent@cnam.fr
%revision du 13/11/2012
%modification du 19/12/2012: changement longueur de correlation
%revision 31/08/2015: changement nom fonction

%Rasmussen 2006 p. 83

function [G,dG,ddG]=sexp(xx,long)

%verification de la dimension de la longueur de correlation
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
    error('mauvaise dimension du parametre interne');
end


%calcul de la valeur de la fonction au point xx
td=-xx.^2.*long.^2/2;
%td=-xx.^2./(2*long.^2);
ev=exp(sum(td,2));

if nb_out>0
    G=ev;
end
if nb_out>1
    dG=-xx.*long.^2.*ev(:,ones(1,nb_comp));
    %dG=-xx./long.^2.*ev(:,ones(1,nb_comp));
end
if nb_out>2
    %calcul des derivees secondes
    
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    %si on ne demande le calcul des derivees secondes en un seul point, on
    %les stocke dans une matrice
    if nb_pt==1
        ddG=zeros(nb_comp);
        for ll=1:nb_comp
            for mm=1:nb_comp
                if(mm==ll)
                    ddG(mm,ll)=ev*(xx(mm)^2*long(1,mm)^4-long(1,mm)^2);
                    %ddG(mm,ll)=ev*(xx(mm)^2./long(1,mm)^2)./long(1,mm)^2;
                else
                    ddG(mm,ll)=ev*4*long(1,mm)*long(1,ll)*xx(ll)*xx(mm);
                    %ddG(mm,ll)=ev*xx(ll)*xx(mm)/(long(1,mm)*long(1,ll));
                end
            end
        end
        
        %si on demande le calcul des derivees secondes en plusieurs point, on
        %les stocke dans un vecteur de matrices
    else
        ddG=zeros(nb_comp,nb_comp,nb_pt);
        for ll=1:nb_comp
            for mm=1:nb_comp
                if(mm==ll)
                    ddG(mm,ll,:)=ev.*(xx(:,mm).^2.*long(1,mm)^4-long(1,mm).^2);
                    %ddG(mm,ll,:)=ev*(xx(:,mm).^2./long(1,mm)^2)./long(1,mm)^2;
                else
                    ddG(mm,ll,:)=4*ev.*long(1,mm)*long(1,ll).*xx(:,ll).*xx(:,mm);
                    %ddG(mm,ll,:)=ev*xx(:,ll)*xx(:,mm)/(long(1,mm)*long(1,ll));
                end
            end
        end
    end
end
if nb_out>3
    error('Mauvais argument de sortie de la fonction sexp.m');
end
