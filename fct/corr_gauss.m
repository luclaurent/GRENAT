%%fonction de corrélation gauss (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function [corr,dcorr,ddcorr]=corr_gauss(xx,theta)

%vérification de la dimension de theta
lt=length(theta);
%nombre de points à évaluer
pt_eval=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);

if lt==1
    %theta est un réel, alors on en fait une matrice de la dimension de xx
    theta = repmat(theta,pt_eval,nb_comp);
elseif lt~=nb_comp
    error('mauvaise dimension de theta');
end

%calcul de la valeur de la fonction au point xx
td=-xx.^2.*theta;
ev=exp(sum(td,2));
repmat(ev,1,nb_comp)
if nargout==1
    corr=ev;
elseif nargout==2
    corr=ev;
    dcorr=-2*theta.*xx.*repmat(ev,1,nb_comp);
elseif nargout==3
    corr=ev;
    dcorr=-2*theta.*xx.*repmat(ev,1,nb_comp);
    %stockage des dérivées secondes en chaque point sous forme de vecteurs
    % pour 4 variables de conception, on aura alors les dérivées classées
    % de la manière suivantes
    % dx1dx1 dx2dx2 dx3dx3 dx4dx4 dx1dx2 dx1dx3 dx1dx4 dx2dx3 dx2dx4 dx3dx4
    ddcorr=zeros(pt_eval,nb_comp*(1+nb_comp)*1/2);
    for ll=1:nb_comp
        ddcorr(:,ll)=4*theta(ll)^2.*xx(:,ll).^2.*ev-...
            2*theta(ll).*ev;
    end
    ind=1;
    for ll=1:nb_comp
        for mm=(ll+1):nb_comp
                ddcorr(:,nb_comp+ind)=4*theta(mm)*theta(ll)*xx(:,ll).*...
                    xx(:,mm).*ev;
                ind=ind+1;
        end
    end
    
else
    error('Mauvais argument de sortie de la fonction corr_gauss');
end