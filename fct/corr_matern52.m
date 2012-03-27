%%fonction de correlation Matern (5/2)
%%L. LAURENT -- 23/01/2011 -- luc.laurent@ens-cachan.fr

function [corr,dcorr,ddcorr]=corr_matern52(xx,long)

%verification de la dimension de lalongueur de correlations
lt=size(long);
%nombre de points a  evaluer
pt_eval=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);

%La longueur de correlation est définie pour toutes les composantes de xx
if lt(1)*lt(2)==1
    long = repmat(long,pt_eval,nb_comp);
elseif lt(1)*lt(2)==nb_comp
    long = repmat(long,pt_eval,1);
elseif lt(1)*lt(2)~=nb_comp
    error('mauvaise dimension de la longueur de correlation');
end

%calcul de la valeur de la fonction au point xx
td=-abs(xx)./long*sqrt(5);
co=1+sqrt(5)./long.*abs(xx)+5*xx.^2./(3.*long.^2);
pc=co.*exp(td);
ev=prod(pc,2);


if nargout==1
    corr=ev;
elseif nargout==2
    corr=ev;
    dco=-(5./(3*long.^2).*xx+5*sqrt(5)./(3*long.^3).*xx.^2.*sign(xx)).*exp(-sqrt(5)./long.*abs(xx));
    %calcul des derivees selon chacune des composantes
    pr=zeros(size(xx));
    for ii=1:nb_comp
        pcc=pc;
        pcc(:,ii)=[];
        pr(:,ii)=prod(pcc,2);
    end
    dcorr=dco.*pr;
elseif nargout==3
    corr=ev;
    dco=-(5./(3*long.^2).*xx+5*sqrt(5)./(3*long.^3).*xx.^2.*sign(xx)).*exp(-sqrt(5)./long.*abs(xx));
   % dco
    %calcul des derivees selon chacune des composantes
    pr=zeros(size(xx));
    for ii=1:nb_comp
        pcc=pc;
        pcc(:,ii)=[];
        pr(:,ii)=prod(pcc,2);
    end
    dcorr=dco.*pr;  
    
    %calcul des derivees secondes    
    
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    %si on ne demande le calcul des derivees secondes en un seul point, on
    %les stocke dans une matrice 
    if pt_eval==1
        dm=zeros(nb_comp);
        ddco=(-5./(3*long.^2)-5*sqrt(5)./(3*long.^3).*abs(xx)+25./(3*long.^4).*xx.^2).*exp(-sqrt(5)./long.*abs(xx));
        di=ddco.*pr;
        
        for ll=1:nb_comp
           for mm=1:nb_comp
               pcc=pc;
               pcc([ll mm])=[];
               prr=prod(pcc,2);
               dm(mm,ll)=dco(ll)*dco(mm)*prr;
           end
        end
        %dm=dm+transpose(dm);
        ddcorr=diag(di)+dm;
       
    %si on demande le calcul des derivees secondes en plusieurs point, on
    %les stocke dans un vecteur de matrices
    else
        dm=zeros(nb_comp,nb_comp,pt_eval);
        ddcorr=dm;
        ddco=(5./(3*long.^2)-5*sqrt(5)./(3*long.^3).*abs(xx)+25./(3*long.^4).*xx.^2).*exp(-sqrt(5)./long.*abs(xx));
        di=ddco.*pr;
                
        for ll=1:nb_comp
           for mm=1:nb_comp
               pcc=pc;
               pcc(:,[ll mm])=[];
               prr=prod(pcc,2);
               dm(mm,ll,:)=dco(:,ll).*dco(:,mm).*prr;
           end
        end
        for kk=1:pt_eval
        %    dm(:,:,kk)=dm(:,:,kk)+transpose(dm(:,:,kk));
            ddcorr(:,:,kk)=diag(di(kk,:))+dm(:,:,kk);
        end
        
        
        
        
%         ddcorr=zeros(nb_comp,nb_comp,pt_eval);
%         for ll=1:nb_comp
%            for mm=1:nb_comp
%                 if(mm==ll)                    
%                     ddcorr(mm,ll,:)=4*theta(mm)^2.*xx(:,ll).^2.*ev-2*theta(ll).*ev;
%                 else
%                     ddcorr(mm,ll,:)=4*theta(mm)*theta(ll).*xx(:,ll).*xx(:,mm).*ev;
%                 end
%            end
%         end

    end
   
    
else
    error('Mauvais argument de sortie de la fonction corr_gauss');
end