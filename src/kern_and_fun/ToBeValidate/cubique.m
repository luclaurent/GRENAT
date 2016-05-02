%% Fonction: Cubique 
%% L. LAURENT -- 11/05/2010 (r: 31/08/2015) -- luc.laurent@cnam.fr

function [G,dG,ddG]=cubique(xx,long)

%verification de la dimension du parametre interne
lt=length(long);
%nombre de points a evaluer
pt_eval=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);
%nombre de sorties
nb_out=nargout;

if lt==1
    %theta est un reel, alors on en fait une matrice
    long = repmat(long,pt_eval,nb_comp);
elseif lt~=nb_comp
    error('mauvaise dimension deu parametre interne');
end
%calcul de la valeur de la fonction au point xx
td=min(1,long.*abs(xx));
sp=1-3.*td.^2+2.*td.^3;
ev=prod(sp,2);

%Evaluation ou derivee
if nb_out==1
    G=ev;
elseif nb_out==2
    G=zeros(d,1);
    for ll=1:d
        evd=6*long(ll)*sign(xx(:,ll)).*td(:,ll).*(td(:,ll)-1);
        dG(ll,:)=evd.*prod(sp(:,[1:ll-1 ll+1:d]),2);
    end
else
    error('Mauvais argument de la fonction cubique');
end
