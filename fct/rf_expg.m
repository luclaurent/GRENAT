%%fonction de rfelation exponentielle generalisee (RBF)
%%L. LAURENT -- 20/11/2012 -- luc.laurent@ens-cachan.fr

% nd+1 parametres possible avec nd la dimension du pb
% le parametre para(nd+1) ou para(end) doit être compris entre 1 et n
% (n vaut généralement 2)

function [rf,drf,ddrf]=rf_expg(xx,para)



%verification de la dimension de para
lt=size(para);
%nombre de points a evaluer
nb_pt=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);
%nombre de sorties
nb_out=nargout;

%La longueur de rfelation est definie pour toutes les composantes de xx
%(la puissance est unique)
if  lt(1)*lt(2)==2
    pow=para(end);
    long=para(1);
    long = long*ones(nb_pt,nb_comp);
elseif lt(1)*lt(2)==nb_comp+1
    pow=para(end);
    long=para(1:end-1);
    long = long(ones(nb_pt,1),:);
elseif lt(1)*lt(2)~=nb_comp+1
    error('mauvaise dimension de para');
end

%calcul de la valeur de la fonction au point xx
td=-abs(xx).^pow./long;
ev=exp(sum(td,2));

%evaluation ou derivees
if nb_out==1
    rf=ev;
elseif nb_out==2
    rf=ev;
    drf=-pow./long.*sign(xx).*(abs(xx).^(pow-1)).*...
        ev(:,ones(1,nb_comp));
elseif nb_out==3
    rf=ev;
    drf=-pow./long.*sign(xx).*(abs(xx).^(pow-1)).*...
        ev(:,ones(1,nb_comp));
    
    %calcul des derivees secondes
    
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    %si on ne demande le calcul des derivees secondes en un seul point, on
    %les stocke dans une matrice
    if nb_pt==1
        ddrf=zeros(nb_comp);
        for ll=1:nb_comp
            for mm=1:nb_comp
                if(mm==ll)
                    ddrf(mm,ll)=(pow^2.*abs(xx(mm)).^(2*(pow-1))./long(1,mm).^2-...
                        pow.*(pow-1).*abs(xx(mm)).^(pow-1)./long(1,mm)).*ev;
                else 
                    ddrf(mm,ll)=ev/(long(1,mm)*long(1,ll)).*sign(xx(ll)).*...
                        sign(xx(mm)).*abs(xx(ll))^(pow-1)*abs(xx(mm))^(pow-1).*pow^2.*ev;
                end
            end
        end
        
        %si on demande le calcul des derivees secondes en plusieurs point, on
        %les stocke dans un vecteur de matrices
    else
        ddrf=zeros(nb_comp,nb_comp,nb_pt);
        for ll=1:nb_comp
            for mm=1:nb_comp
                if(mm==ll)
                    ddrf(mm,ll,:)=(pow^2.*abs(xx(:,mm)).^(2*(pow-1))./long(1,mm).^2-...
                        pow.*(pow-1).*abs(xx(:,mm)).^(pow-1)./long(1,mm)).*ev;
                else
                    ddrf(mm,ll,:)=ev./(long(1,mm)*long(1,ll)).*sign(xx(:,ll)).*...
                        sign(xx(:,mm)).*abs(xx(:,ll)).^(pow-1).*abs(xx(:,mm)).^(pow-1).*pow^2.*ev;
                end
                
            end
        end
    end
else
        error('Trop d''arguments de sortie dans l''appel de la fonction rf_expg');
end
