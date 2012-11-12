%%fonction de correlation exponentielle carree ou gaussienne (KRG)
%%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

% voir par exemple Rasmussen 2006 ou Roustant 2010

function [corr,dcorr,ddcorr]=corr_sexp(xx,long)

%verification de la dimension de la longueur de correlation
lt=size(long);
%nombre de points  evaluer
pt_eval=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);

if lt(1)*lt(2)==1
    %long est un reel, alors on en fait une matrice de la dimension de xx
    long = repmat(long,pt_eval,nb_comp);
elseif lt(1)*lt(2)==nb_comp
    long = repmat(long,pt_eval,1);
elseif lt(1)*lt(2)~=nb_comp
    error('mauvaise dimension de la longueur de correlation');
end

%calcul de la valeur de la fonction au point xx
td=-xx.^2./(2*long.^2);
ev=exp(sum(td,2));

%nouvelle implementation issue de Lockwood 2010/2012
%calcul derivees premieres et seconde selon chaque dimension puis
%combinaison
if nb_out==2
    %calcul derivees premieres
    dk=-3./long.^2.*xx.*etd;
    L=[ones(nb_pt,1) cumprod(pc(1:end-1),2)];
    U=cumprod(pc(:,end-1:-1:1),2);U=[U(:,end:-1:1) ones(nb_pt,1)];
    dcorrn=L.*U.*dk;
    
elseif nb_out==3
    
    %calcul derivees premieres
    dk=-3./long.^2.*xx.*etd;
    % signification U et L cf. Lockwood 2010
    L=[ones(nb_pt,1) cumprod(pc(:,1:end-1),2)];
    U=cumprod(pc(:,end:-1:2),2);U=[U(:,end:-1:1) ones(nb_pt,1)];
    LdU=L.*U;
    %derivees premieres
    dcorrn=LdU.*dk;
    
    %calcul derivees secondes
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    ddk=3./long.^2.*(sqrt(3)./long.*abs(xx)-1).*etd;
    
    if nb_pt==1
        % si un seul point d'evaluation (sortie derivees secondes sous la
        % forme d'une matrice)
        % signification U, L et M cf. Lockwood 2010
        prd=dk'*dk;
        prd(1:nb_comp+1:nb_comp^2)=ddk;
        %
        mm=[1 1 pc(2:nb_comp-1)];
        M=mm(ones(nb_comp,1),:);
        M=triu(M,2)+tril(ones(nb_comp),1);
        M=cumprod(M,2);
        %
        LUMt=triu(L'*U.*M,1);
        LUM=LUMt+LUMt';
        LUM(1:nb_comp+1:nb_comp^2)=LdU;
        %derivees secondes
        ddcorrn=LUM.*prd;
    else
        % si plusieurs points alors on stocke les derivees secondes dans un
        % vecteur de matrices
        IX_diag=repmat(logical(eye(nb_comp)),[1 1 nb_pt]); %acces diatgonales des N-D array
        %passage grandeur en ND-array
        dk=reshape(dk',1,nb_comp,nb_pt);
        Lr=reshape(L',nb_comp,1,nb_pt); % + transpose
        Ur=reshape(U',1,nb_comp,nb_pt);
        %
        prd=multiTimes(dk,dk,2.1);
        prd(IX_diag)=ddk';
        
        mm=[1 1 3:nb_comp];
        masq1=mm(ones(nb_comp,1),:); %decalage indice pour cause decalage ds pc
        masq1=triu(masq1,2)+tril(ones(nb_comp),1);
        %
        pcc=reshape([ones(1,nb_pt);pc'],1,nb_comp+1,nb_pt);
        M=reshape(pcc(1,masq1,:),nb_comp,nb_comp,nb_pt);
        %
        masq2=triu(ones(nb_comp));
        M=cumprod(M,2);
        M=M.*repmat(masq2,[1 1 nb_pt]);
        LUMt=multiTimes(Lr,Ur,2).*M;
        LUM=LUMt+multitransp(LUMt);
        LUM(IX_diag)=LdU';
        %derivees secondes
        ddcorrn=LUM.*prd;
    end
end

if nargout==1
    corr=ev;
elseif nargout==2
    corr=ev;
    dcorr=-xx./(long.^2).*repmat(ev,1,nb_comp);
elseif nargout==3
    corr=ev;
    dcorr=-xx./(long.^2).*repmat(ev,1,nb_comp);
    
    %calcul des derivees secondes
    
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    %si on ne demande le calcul des derivees secondes en un seul point, on
    %les stocke dans une matrice
    if pt_eval==1
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
        ddcorr=zeros(nb_comp,nb_comp,pt_eval);
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
    
else
    error('Mauvais argument de sortie de la fonction corr_gauss');
end