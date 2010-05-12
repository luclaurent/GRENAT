%%fonction de corrélation linéaire (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function corr=corr_lin(xx,theta,type)

%vérification de la dimension de theta
lt=length(theta);
d=size(xx,2);

if lt==1
    %theta est un réel, alors on en fait une matrice
    theta = repmat(theta,1,d);
elseif lt~=d
    error('mauvaise dimension de theta');
end

%calcul de la valeur de la fonction au point xx
td=max(0,1-theta.*abs(xx));
ev=prod(td,2);

%évaluation ou dérivée
if strcmp(type,'e')
    corr=ev;
elseif strcmp(type,'d')
   % corr=-theta.*prod(td(:,1:j-1 j+1:n]),2).*sign(xx);
else
    error('Mauvais argument de la fonction corr_lin');
end  
end