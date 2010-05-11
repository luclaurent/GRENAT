%%fonction de corrélation sphérique (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function corr=corr_spherique(xx,theta,type)

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
ev=prod(sp,2);

%évaluation ou dérivée
if strcmp(type,'e')
    corr=ev;
elseif strcmp(type,'d')
    corr=zeros(d,1);
    for ll=1:d
        evd=1.5*theta(ll)*sign(xx(:,ll)).*(td(:,ll).^2-1);
        corr(ll,:)=evd.*prod(sp(:,[1:ll-1 ll+1:d]),2);
    end
else
    error('Mauvais argument de la fonction corr_cubique');
end 

end