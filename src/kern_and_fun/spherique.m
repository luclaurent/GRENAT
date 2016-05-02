%% Fonction: spherique
%%L. LAURENT -- 11/05/2010 (r: 31/08/2015) -- luc.laurent@cnam.fr

function G=spherique(xx,theta,type)

%verification de la dimension du parametre interne
lt=length(theta);
d=size(xx,2);

if lt==1
    %theta est un reel, alors on en fait une matrice
    theta = repmat(theta,1,d);
elseif lt~=d
    error('mauvaise dimension deu parametre interne');
end

%calcul de la valeur de la fonction au point xx
td=min(1,theta.*abs(xx));
sp=1-1.5.*td+0.5.*td.^3;
ev=prod(sp,2);

%Evaluation ou derivee
if strcmp(type,'e')
    G=ev;
elseif strcmp(type,'d')
    G=zeros(d,1);
    for ll=1:d
        evd=1.5*theta(ll)*sign(xx(:,ll)).*(td(:,ll).^2-1);
        G(ll,:)=evd.*prod(sp(:,[1:ll-1 ll+1:d]),2);
    end
else
    error('Mauvais argument de la fonction spherique.m');
end 

end
