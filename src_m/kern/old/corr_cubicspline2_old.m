%%fonction de correlation Cubic Spline 2
%%L. LAURENT -- 12/11/2012 -- luc.laurent@lecnam.net

function [corr,dcorr,ddcorr]=corr_cubicspline2_old(xx,long)

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
td=abs(xx)./long;
%zone de calcul (fonction definie par morceau)
b1=0;b2=0.2;b3=1;
IX1=(b1<=td).*(td<=b2);
IX2=(b2<=td).*(td<=b3);
IX3=(td<=b3);

%calcul des 3 fonctions
ev1=1-6.*td.^2+6.*td.^3;
ev2=2*(1-td).^3;
ev3=zeros(size(td));
pc=ev1.*IX1+ev2.*IX2+ev3.*IX3;

if nb_out==1
    %reponse
    corr=prod(pc,2);
elseif nb_out==2
    %reponse
    corr=prod(pc,2);
    %derivees premieres
    dk1=-12.*xx./long.^2+18.*sign(xx).*xx.^2./long.^3;
    dk2=-6.*sign(xx).*(1-td).^2./long;
    dk3=ev3;
    dco=dk1.*IX1+dk2.*IX2+dk3.*IX3;
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
    %reponse
    corr=prod(pc,2);
    %derivees premieres
    dk1=-12.*xx./long.^2+18.*sign(xx).*xx.^2./long.^3;
    dk2=-6.*sign(xx).*(1-td).^2./long;
    dk3=ev3;
    dco=dk1.*IX1+dk2.*IX2+dk3.*IX3;
    %calcul des derivees selon chacune des composantes
    pr=zeros(size(xx));
    for ii=1:nb_comp
        pcc=pc;
        pr(:,ii)=prod(pcc(:,[1:(ii-1) (ii+1):end]),2);
    end
    dcorr=dco.*pr;
    
    %calcul des derivees secondes
    
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    %si on ne demande le calcul des derivees secondes en un seul point, on
    %les s%tocke dans une matrice
    if nb_pt==1
        dm=zeros(nb_comp);
        ddk1=36./long.^3.*abs(xx)-12./long.^2;
        ddk2=12.*(1-td)./long.^2;
        ddk3=ev3;
        ddco=ddk1.*IX1+ddk2.*IX2+ddk3.*IX3;
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
        ddk1=36./long.^3.*abs(xx)-12./long.^2;
        ddk2=12.*(1-td)./long.^2;
        ddk3=ev3;
        ddco=ddk1.*IX1+ddk2.*IX2+ddk3.*IX3;
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
    
    
else
    error('Mauvais argument de sortie de la fonction corr_cubispline2');
end

