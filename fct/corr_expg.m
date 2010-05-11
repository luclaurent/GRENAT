%%fonction de corrélation exponentielle généralisée (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function corr=corr_expg(xx,theta,type)

%vérification de la dimension de theta
lt=length(theta);
d=size(xx);

if lt==1
    %theta est un réel, alors on en fait une matrice
    theta = repmat(theta,1,d+1);
elseif lt~=d+1
    error('mauvaise dimension de theta');
end

%calcul de la valeur de la fonction au point xx
td=-abs(xx).^theta(d+1).*theta(1:d);
ev=exp(sum(td,2));

%évaluation ou dérivée
if strcmp(type,'e')
    corr=ev;
elseif strcmp(type,'d')
    corr=theta(d+1).*theta(1:d).*sign(xx).*(abs(xx).^theta(d+1)).*repmat(ev,1,d);
else
    error('Mauvais argument de la fonction corr_cubique');
end  
        