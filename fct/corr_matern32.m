%%fonction de correlation Matern (3/2)
%%L. LAURENT -- 23/01/2011 -- luc.laurent@ens-cachan.fr
%revision le 09/11/2012

function [corr,dcorr,ddcorr]=corr_matern32(xx,long)

%verification de la dimension de lalongueur de correlations
lt=size(long);

%nombre de points a evaluer
nb_pt=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);
%nombre de sortie
nb_out=nargout;


%La longueur de correlation est definie pour toutes les composantes de xx
if lt(1)*lt(2)==1
    long = long*ones(nb_pt,nb_comp);
elseif lt(1)*lt(2)==nb_comp
    long = long(ones(nb_pt,1),:);
elseif lt(1)*lt(2)~=nb_comp
    error('mauvaise dimension de la longueur de correlation');
end

%calcul de la valeur de la fonction au point xx
etd=exp(-abs(xx)./long*sqrt(3));
co=1+sqrt(3)./long.*abs(xx);
pc=co.*etd;
corr=prod(pc,2);

%nouvelle implementation issue de Lockwood 2010/2012
%calcul derivees premieres et seconde selon chaque dimension puis
%combinaison
if nb_out==2
    
    %calcul derivees premieres
    dk=-3./long.^2.*xx.*etd;
    L=[ones(nb_pt,1) cumprod(pc(1:end-1),2)];
    U=cumprod(pc(:,end-1:-1:1),2);U=[U(:,end:-1:1) ones(nb_pt,1)];
    dcorr=L.*U.*dk;

elseif nb_out==3
    
    %calcul derivees premieres
    dk=-3./long.^2.*xx.*etd;
  %  tic
  % signification U et L cf. Lockwood 2010
    L=[ones(nb_pt,1) cumprod(pc(:,1:end-1),2)];
    U=cumprod(pc(:,end:-1:2),2);U=[U(:,end:-1:1) ones(nb_pt,1)];
    LdU=L.*U;
    dcorr=LdU.*dk;
   % toc
    %calcul derivees secondes
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
   % tic
    ddk=3./long.^2.*(sqrt(3)./long.*abs(xx)-1).*etd;
    
    if nb_pt==1
        % si un seul point d'evaluation (sortie derivees secondes sous la
        % forme d'une matrice)
        % signification U, L et M cf. Lockwood 2010
        prd=dk'*dk;
        prd(1:nb_comp+1:nb_comp^2)=ddk;
        mm=[1 1 pc(2:nb_comp-1)];
        M=mm(ones(nb_comp,1),:);
        M=triu(M,2)+tril(ones(nb_comp),1);
        M=cumprod(M,2);
        LUMt=triu(L'*U.*M,1);
        LUM=LUMt+LUMt';
        LUM(1:nb_comp+1:nb_comp^2)=LdU;
        ddcorr=LUM.*prd;
    else
        % si plusieurs points alors on stocke les derivees secondes dans un
        % vecteur de matrices
        IX_diag=repmat(logical(eye(nb_comp)),[1 1 nb_pt]); %acces diatgonales des N-D array
        %passage grandeur en ND-array
        dk=reshape(dk',1,nb_comp,nb_pt);
        Lr=reshape(L',nb_comp,1,nb_pt); % + transpose
        Ur=reshape(U',1,nb_comp,nb_pt);
        
        prd=multiTimes(dk,dk,2.1);
        prd(IX_diag)=ddk';
        pcc=reshape([ones(1,nb_pt);pc'],1,nb_comp+1,nb_pt);
        mm=[1 1 3:nb_comp];
        masq1=mm(ones(nb_comp,1),:); %decalage indice pour cause decalage ds pc
        masq1=triu(masq1,2)+tril(ones(nb_comp),1);
        M=reshape(pcc(1,masq1,:),nb_comp,nb_comp,nb_pt);
        masq2=triu(ones(nb_comp));
        M=cumprod(M,2);
        M=M.*repmat(masq2,[1 1 nb_pt]);
        LUMt=multiTimes(Lr,Ur,2).*M;
        LUM=LUMt+multitransp(LUMt);
        
        LUM(IX_diag)=LdU';
        ddcorr=LUM.*prd;
    end

else
    error('Mauvais argument de sortie de la fonction corr_matern32');
end