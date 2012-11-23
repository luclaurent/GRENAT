%%fonction de correlation exponentielle carree (gaussienne)
%%L. LAURENT -- 18/01/2012 -- luc.laurent@ens-cachan.fr
%revision du 12/11/2012 (issue de Lockwood 2010)
%Rasmussen 2006 p. 83

function [corr,dcorr,ddcorr]=corr_sexp_new(xx,long)

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
    error('mauvaise dimension de la longueur de correlation');
end


%calcul de la valeur de la fonction au point xx
l2=long.^2;
td=-xx.^2./(2*l2);
pc=exp(td);

if nb_out==1
    %reponses
    corr=prod(pc,2);
elseif nb_out==2
    %reponses
    corr=prod(pc,2);
    %derivees premieres
    dcorr=-xx./l2.*corr(:,ones(1,nb_comp));
elseif nb_out==3
    %reponses
    corr=prod(pc,2);
    %derivees premieres
    coef=-xx./l2;
    rcorr=corr(:,ones(1,nb_comp));
    dcorr=coef.*rcorr;
    %%derivees secondes
    ddk=rcorr./l2.^2.*(xx.^2-l2);
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    %si on ne demande le calcul des derivees secondes en un seul point, on
    %les stocke dans une matrice
    if nb_pt==1
        ddcorr=corr.*(coef'*coef);
        ddcorr(1:nb_comp+1:nb_comp^2)=ddk;
    else
        ll=logical(eye(nb_comp));
        IX_diag=ll(:,:,ones(nb_pt,1));
        
        dk=reshape(coef',1,nb_comp,nb_pt);
        cc=reshape(corr,1,1,nb_pt);
        cc=cc(ones(nb_comp,1),ones(nb_comp,1),:);
        
        ddcorr=multiTimes(dk,dk,2.1);
        ddcorr=cc.*ddcorr;
        ddcorr(IX_diag)=ddk';
    end
else
    error('Mauvais argument de sortie de la fonction corr_sexp');
end