%%fonction de corrélation cubique (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function corr=corr_cubique(xx,theta,type)

%vérification de la dimension de theta
lt=length(theta);
%nombre de points à évaluer
pt_eval=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);

if lt==1
    %theta est un réel, alors on en fait une matrice
    theta = repmat(theta,pt_eval,nb_comp);
elseif lt~=nb_comp
    error('mauvaise dimension de theta');
end
%calcul de la valeur de la fonction au point xx
td=min(1,theta.*abs(xx));
sp=1-3.*td.^2+2.*td.^3;
ev=prod(sp,2);

%évaluation ou dérivée
if strcmp(type,'e')
    corr=ev;
elseif strcmp(type,'d')
    corr=zeros(d,1);
    for ll=1:d
        evd=6*theta(ll)*sign(xx(:,ll)).*td(:,ll).*(td(:,ll)-1);
        corr(ll,:)=evd.*prod(sp(:,[1:ll-1 ll+1:d]),2);
    end
else
    error('Mauvais argument de la fonction corr_cubique');
end