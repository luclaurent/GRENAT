%%fonction de corrélation exponentielle généralisée (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function [corr,dcorr,ddcorr]=corr_expg(xx,theta)

%vérification de la dimension de theta
lt=length(theta);
d=size(xx,2);

if d>1 & lt==2
    theta = [repmat(theta,1,d) theta(2)];
elseif lt~=d+1
    error('mauvaise dimension de theta');
end

%calcul de la valeur de la fonction au point xx
td=-abs(xx).^theta(d+1).*theta(1:d);
ev=exp(sum(td,2));

%évaluation ou dérivées
if nargout==1
    corr=ev;
elseif nargout==2
    corr=ev;
    dcorr=-theta(d+1).*theta(1:d).*sign(xx).*(abs(xx).^(theta(d+1)-1)).*...
        repmat(ev,1,d);
elseif nargout==3
    corr=ev;
    dcorr=-theta(d+1).*theta(1:d).*sign(xx).*(abs(xx).^(theta(d+1)-1)).*...
        repmat(ev,1,d);
    ddcorr=zeros(d);
    %calcul de la matrice des dérivées secondes
    for ll=1:d
        for mm=1:d
            ddcorr(mm,ll)=theta(ll)*theta(mm)*theta(d+1)^2*...
            sign(xx(ll))*sign(xx(mm))*abs(xx(ll))^(theta(d+1)-1)*...
            abs(xx(mm))^(theta(d+1)-1)*ev;
        end
    end
else
    error('Trop d''arguments de sortie dans l''appel de la fonction corr_exp');
end  

        