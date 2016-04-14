%%fonction de correlation Matern (3/2)
%%L. LAURENT -- 23/01/2011 -- luc.laurent@lecnam.net

function [corr,dcorr,ddcorr]=corr_matern32_old(xx,long)

%verification de la dimension de lalongueur de correlations
lt=size(long);

%nombre de points a evaluer
nb_pt=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);
%nombre output
nb_out=nargout;


%La longueur de correlation est definie pour toutes les composantes de xx
if lt(1)*lt(2)==1
    long =long*ones(nb_pt,nb_comp);
elseif lt(1)*lt(2)==nb_comp
    long = long(ones(nb_pt,1),:);
elseif lt(1)*lt(2)~=nb_comp
    error('mauvaise dimension de la longueur de correlation');
end

%calcul de la valeur de la fonction au point xx
etd=exp(-abs(xx)./long*sqrt(3));
co=1+sqrt(3)./long.*abs(xx);
pc=co.*etd;
ev=prod(pc,2);






if nb_out==1
    corr=ev;
elseif nb_out==2
    %tic
    corr=ev;
    dco=-3./long.^2.*xx.*exp(-sqrt(3)./long.*abs(xx));
    %calcul des derivees selon chacune des composantes
    pr=zeros(size(xx));
    pcc=pc;
    for ii=1:nb_comp
        pr(:,ii)=prod(pcc(:,[1:(ii-1) (ii+1):end]),2);
    end
    dcorr=dco.*pr;
%     all(abs(dcorr(:)-dcorrn(:))<10^-14)
%     %toc
elseif nb_out==3
    corr=ev;
    dco=-3./long.^2.*xx.*exp(-sqrt(3)./long.*abs(xx));
    %calcul des derivees selon chacune des composantes
    %tic
    pr=zeros(size(xx));
    for ii=1:nb_comp
        pcc=pc;
        pr(:,ii)=prod(pcc(:,[1:(ii-1) (ii+1):end]),2);
    end
    dcorr=dco.*pr;
    %toc

    %calcul des derivees secondes
    
    %suivant la taille de l'evaluation demandee on s%tocke les derivees
    %secondes de manieres differentes
    %si on ne demande le calcul des derivees secondes en un seul point, on
    %les s%tocke dans une matrice
    if nb_pt==1
        dm=zeros(nb_comp);
        ddco=3./long.^2.*(sqrt(3)./long.*abs(xx)-1).*exp(-sqrt(3)./long.*abs(xx));
        %tic
        di=ddco.*pr;
        
        for ll=1:nb_comp
            for mm=ll+1:nb_comp
                pcc=pc;
                pcc([ll mm])=[];
                prr=prod(pcc,2);
                dm(mm,ll)=dco(ll)*dco(mm)*prr;
            end
        end
        dm=dm+transpose(dm);
        ddcorr=diag(di)+dm;
        %toc
        %si on demande le calcul des derivees secondes en plusieurs point, on
        %les s%tocke dans un vecteur de matrices
    else
        dm=zeros(nb_comp,nb_comp,nb_pt);
        ddcorr=dm;
        ddco=3./long.^2.*(sqrt(3)./long.*abs(xx)-1).*exp(-sqrt(3)./long.*abs(xx));
        di=ddco.*pr;
        %tic
        for ll=1:nb_comp
            for mm=ll+1:nb_comp
                pcc=pc;
                pcc(:,[ll mm])=[];
                prr=prod(pcc,2);
                dm(mm,ll,:)=dco(:,ll).*dco(:,mm).*prr;
                %prr
            end
        end
        for kk=1:nb_pt
            dm(:,:,kk)=dm(:,:,kk)+transpose(dm(:,:,kk));
            ddcorr(:,:,kk)=diag(di(kk,:))+dm(:,:,kk);
        end
        %toc
        
    end
%    all(abs(dcorr(:)-dcorrn(:))<10^-14)
%     all(abs(ddcorr(:)-ddcorrn(:))<10^-14)
%     abs(ddcorr(:)-ddcorrn(:))
%     ddcorr
%     ddcorrn
   
    
else
    error('Mauvais argument de sortie de la fonction corr_matern32');
end

