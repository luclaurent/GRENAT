%% Fonction: exponentielle
%% L. LAURENT -- 11/05/2010 (r: 31/08/2015) -- luc.laurent@cnam.fr

function [G,dG,ddG]=expo(xx,theta)

%verification de la dimension du parametre interne
lt=length(theta);
d=size(xx,2);

if lt==1
    %theta est un réel, alors on en fait une matrice
    theta = repmat(theta,1,d);
elseif lt~=d
    error('mauvaise dimension deu parametre interne');
end

%calcul de la valeur de la fonction au point xx
td=-abs(xx).*theta;
ev=exp(sum(td,2));

%évaluation ou dérivée
if nargout==1
    G=ev;
elseif nargout==2
    G=ev;
    dG=-theta.*sign(xx).*ev;
elseif nargout==3
    G=ev;
    dG=-theta.*sign(xx).*ev;
    ddG=zeros(d);
    %calcul de la matrice des dérivées secondes
    for ll=1:d
        for mm=1:d
            ddG(mm,ll)=theta(ll)*theta(mm)*sign(xx(ll))*sign(xx(mm))*ev;
        end
    end
else
    error('Trop d''arguments de sortie dans l''appel de la fonction corr_exp');
end  
