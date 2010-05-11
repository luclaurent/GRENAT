%%fonction de corrélation sphérique (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function corr=corr_spherique(xx,theta)

%vérification de la dimension de theta
lt=length(theta);
d=size(xx);

if lt==1
    %theta est un réel, alors on en fait une matrice
    theta = repmat(theta,1,d);
elseif lt~=d
    error('mauvaise dimension de theta');
end

%calcul de la valeur de la fonction au point xx
td=min(0,1-theta.*abs(xx));
sp=1-1.5.*td+0.5.*td.^3;
corr=prod(sp,2);

end