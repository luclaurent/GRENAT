%%fonction de corrélation spline (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function corr=corr_spline(xx,theta,type)

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
sp=zeros(size(td,1));
for kk=1:size(td,1)
    if (0=<td(kk) && td(kk)=<0.2)
        sp(kk)=1-15*td(kk)^2+30*td(kk)^3;
    elseif (0.2=<td(kk) && td(kk)=<1)
        sp(kk)=1.25*(1-td(kk))^3;
    else
        sp(kk)=0;
    end

corr=prod(sp,2);

end