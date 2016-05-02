%%fonction de corrélation exponentielle (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function [corr,dcorr,ddcorr]=corr_exp(xx,theta)

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
if nargout==1
    corr=ev;
elseif nargout==2
    corr=ev;
    dcorr=-theta.*sign(xx).*ev;
elseif nargout==3
    corr=ev;
    dcorr=-theta.*sign(xx).*ev;
    ddcorr=zeros(d);
    %calcul de la matrice des dérivées secondes
    for ll=1:d
        for mm=1:d
            ddcorr(mm,ll)=theta(ll)*theta(mm)*sign(xx(ll))*sign(xx(mm))*ev;
        end
    end
else
    error('Trop d''arguments de sortie dans l''appel de la fonction corr_exp');
end  