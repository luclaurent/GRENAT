%%fonction de correlation exponentielle generalisee (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr
% revision le 14/11/2012 + inclusion methode de Lockwood 2010

% nd+1 parametres possible avec nd la dimension du pb

function [corr,dcorr,ddcorr]=corr_expg(xx,para)

%verification de la dimension de para
lt=size(para);
%nombre de points a evaluer
nb_pt=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);
%nombre de sorties
nb_out=nargout;

%La longueur de correlation est definie pour toutes les composantes de xx
%(la puissance est unique)
if  lt(1)*lt(2)==1
    pow=para(end);
    long=para(1:end);
    long = long*ones(nb_pt,nb_comp);
elseif lt(1)*lt(2)==nb_comp+1
    pow=para(end);
    long=para(1:end);
    long = long(ones(nb_pt,1),:);
elseif lt(1)*lt(2)~=nb_comp+1
    error('mauvaise dimension de para');
end

%calcul de la valeur de la fonction au point xx
td=-abs(xx).^pow./long;
ev=exp(sum(td,2));

%evaluation ou derivees
if nargout==1
    corr=ev;
elseif nargout==2
    corr=ev;
    dcorr=-pow./long.*sign(xx).*(abs(xx).^(pow-1)).*...
        ev(:,ones(1,nb_comp));
elseif nargout==3
    corr=ev;
    dcorr=-pow.*para.*sign(xx).*(abs(xx).^(pow-1)).*...
        ev(:,ones(1,nb_comp));
    
    %calcul des derivees secondes    
    
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    %si on ne demande le calcul des derivees secondes en un seul point, on
    %les stocke dans une matrice 
    if nb_pt==1
        ddcorr=zeros(nb_comp);
        for ll=1:nb_comp
           for mm=1:nb_comp
                if(mm==ll)
                    ddcorr(mm,ll)=ev/long(1,mm)^4*(xx(mm)^2-long(1,mm)^2);
                else
                    ddcorr(mm,ll)=ev/(long(1,mm)^2*long(1,ll)^2)*xx(ll)*xx(mm);
                end
           end
        end
       
    %si on demande le calcul des derivees secondes en plusieurs point, on
    %les stocke dans un vecteur de matrices
    else
        ddcorr=zeros(nb_comp,nb_comp,nb_pt);
        for ll=1:nb_comp
           for mm=1:nb_comp
                if(mm==ll)                    
                    ddcorr(mm,ll,:)=ev./long(1,mm)^4.*(xx(:,mm).^2-long(1,mm)^2);
                else
                    ddcorr(mm,ll,:)=ev./(long(1,mm)^2*long(1,ll)^2).*xx(:,ll).*xx(:,mm);
                end
           end
        end
    end
    
    %stockage des derivees secondes en chaque point sous forme de vecteurs
    % pour 4 variables de conception, on aura alors les derivees classees
    % de la maniere suivantes
    % dx1dx1 dx2dx2 dx3dx3 dx4dx4 dx1dx2 dx1dx3 dx1dx4 dx2dx3 dx2dx4 dx3dx4
    ddcorr=zeros(nb_pt,nb_comp*(1+nb_comp)*1/2);
    for ll=1:nb_comp
        ddcorr(:,ll)=pow^2*para(ll)^2.*abs(xx(:,ll)).^(pow-1).^2.*ev;
    end
    ind=1;
    for ll=1:nb_comp
        for mm=(ll+1):nb_comp
                ddcorr(:,nb_comp+ind)=pow^2*para(mm)*para(ll)*...
                    abs(xx(:,ll)).^(pow-1).*abs(xx(:,mm)).^(pow-1).*ev;
                ind=ind+1;
        end
    end
    
    
else
    error('Trop d''arguments de sortie dans l''appel de la fonction corr_expg');
end  
