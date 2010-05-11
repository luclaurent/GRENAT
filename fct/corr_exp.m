%%fonction de corrélation exponentielle (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function corr=corr_exp(xx,theta)

%vérification de la dimension de theta
lt=length(theta);
d=size(xx,1);

if lt==1
    %theta est un réel, alors on en fait une matrice
    theta = repmat(theta,1,d);
elseif lt~=d
    error('mauvaise dimension de theta');
end

%calcul de la valeur de la fonction au point xx
td=-abs(xx).*theta;
corr=exp(sum(td,2));
