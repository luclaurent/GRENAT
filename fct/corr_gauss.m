%%fonction de corrélation gauss (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function [corr,dcorr,ddcorr]=corr_gauss(xx,theta)

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
td=-xx.^2.*theta;
ev=exp(sum(td,2));

if nargout==1
    corr=ev;
elseif nargout==2
    corr=ev;
    dcorr=-2*theta.*xx.*repmat(ev,1,d);
elseif nargout==3
    corr=ev;
    dcorr=-2*theta.*xx.*repmat(ev,1,d);
    ddcorr=zeros(d);
    for ll=1:d
        for mm=1:d
            ddcorr(mm,ll)=4*theta(mm)*theta(ll)*xx(ll)*xx(mm)*ev;
        end
    end
else
    error('Mauvais argument de sortie de la fonction corr_gauss');
end