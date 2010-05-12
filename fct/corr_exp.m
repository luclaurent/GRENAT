%%fonction de corrélation exponentielle (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function corr=corr_exp(xx,theta,type)

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
td=-abs(xx).*theta;
ev=exp(sum(td,2));

%évaluation ou dérivée
if strcmp(type,'e')
    corr=ev;
elseif strcmp(type,'d')
    corr=-theta.*sign(ev).*ev;
else
    error('Mauvais argument de la fonction corr_cubique');
end  