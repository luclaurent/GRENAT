%%fonction de correlation Matern (3/2)
%%L. LAURENT -- 23/01/2011 -- luc.laurent@ens-cachan.fr

function [corr,dcorr,ddcorr]=corr_matern32(xx,long)

%verification de la dimension de lalongueur de correlations
lt=size(long);

%nombre de points a evaluer
nb_pt=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);


%La longueur de correlation est definie pour toutes les composantes de xx
if lt(1)*lt(2)==1
    long = repmat(long,nb_pt,nb_comp);
elseif lt(1)*lt(2)==nb_comp
    long = repmat(long,nb_pt,1);
elseif lt(1)*lt(2)~=nb_comp
    error('mauvaise dimension de la longueur de correlation');
end

%calcul de la valeur de la fonction au point xx
etd=exp(-abs(xx)./long*sqrt(3));
co=1+sqrt(3)./long.*abs(xx);
pc=co.*etd;
ev=prod(pc,2);

%nouvelle implementation issue de Lockwood 2010/2012
%calcul derivees premieres et seconde selon chaque dimension puis
%combinaison
if nargout==2
    tic
    %calcul derivees premieres
    dk=-3./long.^2.*xx.*etd;
    L=cumprod(pc,2);L=[ones(nb_pt,1) L(:,1:end-1)];
    U=cumprod(pc(:,end:-1:1),2);U=[U(:,(end-1):-1:1) ones(nb_pt,1)];
    dcorrn=L.*U.*dk;
    toc
elseif nargout==3
    
    %calcul derivees premieres
    dk=-3./long.^2.*xx.*etd;
    tic
    L=cumprod(pc,2);L=[ones(nb_pt,1) L(:,1:end-1)];
    U=cumprod(pc(:,end:-1:1),2);U=[U(:,(end-1):-1:1) ones(nb_pt,1)];
    LdU=L.*U;
    dcorrn=LdU.*dk;
    toc
    %calcul derivees secondes
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    tic
    ddk=3./long.^2.*(sqrt(3)./long.*abs(xx)-1).*etd;
    
    if nb_pt==1
        % si un seul point d'evaluation (sortie derivees secondes sous la
        % forme d'une matrice)
        % signification U, L et M cf. Lockwood 2010
        prd=dk'*dk;
        prd(1:nb_comp+1:nb_comp^2)=ddk;
        M=repmat([1 1 pc(2:nb_comp-1)],nb_comp,1);
        M=triu(M,2)+tril(ones(nb_comp),1);
        M=cumprod(M,2);
        LUMt=triu(L'*U.*M,1);
        LUM=LUMt+LUMt';
        LUM(1:nb_comp+1:nb_comp^2)=LdU;
        ddcorrn=LUM.*prd;
    else
        % si plusieurs points alors on stocke les derivees secondes dans un
        % vecteur de matrices
        IX_diag=repmat(logical(eye(nb_comp)),[1 1 nb_pt]); %acces diatgonales des N-D array
        %passage grandeur en ND-array
        dk=reshape(dk',1,nb_comp,nb_pt);
        Lr=reshape(L',nb_comp,1,nb_pt); % + transpose
        Ur=reshape(U',1,nb_comp,nb_pt);
        
        dkt=multitransp(dk);
        prd=multiprod(dkt,dk);
        prd(IX_diag)=ddk';
        pcc=reshape([ones(1,nb_pt);pc'],1,nb_comp+1,nb_pt);
        masq1=[ones(nb_comp,2) repmat(3:nb_comp,[nb_comp,1])]; %decalage indice pour cause decalage ds pc
        masq1=triu(masq1,2)+tril(ones(nb_comp),1);
        masq=repmat(masq1,[1,1,nb_pt]); 
        M=reshape(pcc(1,masq1,:),nb_comp,nb_comp,nb_pt);
        masq2=triu(ones(nb_comp));
        M=cumprod(M,2);
        M=M.*repmat(masq2,[1 1 nb_pt]);
        LUMt=multiprod(Lr,Ur).*M;
        LUM=LUMt+multitransp(LUMt);
        IX_diag=repmat(logical(eye(nb_comp)),[1 1 nb_pt]);
        LUM(IX_diag)=LdU';
        ddcorrn=LUM.*prd;
    end
    toc
end




if nargout==1
    corr=ev;
elseif nargout==2
    tic
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
%     toc
elseif nargout==3
    corr=ev;
    dco=-3./long.^2.*xx.*exp(-sqrt(3)./long.*abs(xx));
    %calcul des derivees selon chacune des composantes
    tic
    pr=zeros(size(xx));
    for ii=1:nb_comp
        pcc=pc;
        pr(:,ii)=prod(pcc(:,[1:(ii-1) (ii+1):end]),2);
    end
    dcorr=dco.*pr;
    toc

    %calcul des derivees secondes
    
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    %si on ne demande le calcul des derivees secondes en un seul point, on
    %les stocke dans une matrice
    if nb_pt==1
        dm=zeros(nb_comp);
        ddco=3./long.^2.*(sqrt(3)./long.*abs(xx)-1).*exp(-sqrt(3)./long.*abs(xx));
        tic
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
        toc
        %si on demande le calcul des derivees secondes en plusieurs point, on
        %les stocke dans un vecteur de matrices
    else
        dm=zeros(nb_comp,nb_comp,nb_pt);
        ddcorr=dm;
        ddco=3./long.^2.*(sqrt(3)./long.*abs(xx)-1).*exp(-sqrt(3)./long.*abs(xx));
        di=ddco.*pr;
        tic
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
        toc
        
    end
 %   all(abs(dcorr(:)-dcorrn(:))<10^-14)
 %    all(abs(ddcorr(:)-ddcorrn(:))<10^-14)
%     abs(ddcorr(:)-ddcorrn(:))
%     ddcorr
%     ddcorrn
   
    
else
    error('Mauvais argument de sortie de la fonction corr_matern32');
end