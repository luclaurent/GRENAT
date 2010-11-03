%%fonction de corrélation exponentielle généralisée (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function [corr,dcorr,ddcorr]=corr_expg(xx,theta)

%vérification de la dimension de theta
lt=length(theta);
%nombre de points à évaluer
pt_eval=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);

if nb_comp>1 & lt==2
    pow=theta(2);
    theta = repmat(theta(1),pt_eval,nb_comp);
elseif lt~=nb_comp+1
    error('mauvaise dimension de theta');
end

%calcul de la valeur de la fonction au point xx
td=-abs(xx).^pow.*theta;
ev=exp(sum(td,2));

%évaluation ou dérivées
if nargout==1
    corr=ev;
elseif nargout==2
    corr=ev;
    dcorr=-pow.*theta.*sign(xx).*(abs(xx).^(pow-1)).*...
        repmat(ev,1,nb_comp);
elseif nargout==3
    corr=ev;
    dcorr=-pow.*theta.*sign(xx).*(abs(xx).^(pow-1)).*...
        repmat(ev,1,nb_comp);
    ddcorr=zeros(d);
    
    %stockage des dérivées secondes en chaque point sous forme de vecteurs
    % pour 4 variables de conception, on aura alors les dérivées classées
    % de la manière suivantes
    % dx1dx1 dx2dx2 dx3dx3 dx4dx4 dx1dx2 dx1dx3 dx1dx4 dx2dx3 dx2dx4 dx3dx4
    ddcorr=zeros(pt_eval,nb_comp*(1+nb_comp)*1/2);
    for ll=1:nb_comp
        ddcorr(:,ll)=pow^2*theta(ll)^2.*abs(xx(:,ll)).^(pow-1).^2.*ev;
    end
    ind=1;
    for ll=1:nb_comp
        for mm=(ll+1):nb_comp
                ddcorr(:,nb_comp+ind)=pow^2*theta(mm)*theta(ll)*...
                    abs(xx(:,ll)).^(pow-1).*abs(xx(:,mm)).^(pow-1).*ev;
                ind=ind+1;
        end
    end
    
    
else
    error('Trop d''arguments de sortie dans l''appel de la fonction corr_exp');
end  
