%%fonction de corrélation exponentielle généralisée (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function corr=corr_expg(xx,theta)

%vérification de la dimension de theta
lt=length(theta);
d=size(xx);

if lt==1
    %theta est un réel, alors on en fait une matrice
    theta = repmat(theta(1:d-1),1,d-1);
elseif lt~=d+1
    error('mauvaise dimension de theta');
end

%calcul de la valeur de la fonction au point xx
td=-abs(xx).^theta(d).*theta;
corr=exp(sum(td,2));

    
        