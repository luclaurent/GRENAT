%% Fonction: Cubic Spline 2
%% L. LAURENT -- 12/11/2012 (r: 31/08/2015) -- luc.laurent@cnam.fr

function [G,dG,ddG]=cubicspline2(xx,long)

%verification de la dimension du parametre interne
lt=size(long);

%nombre de points a evaluer
nb_pt=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);
%nombre de sorties
nb_out=nargout;


%Le parametre interne est defini pour toutes les composantes de xx
if lt(1)*lt(2)==1
    long = long*ones(nb_pt,nb_comp);
elseif lt(1)*lt(2)==nb_comp
    long = long(ones(nb_pt,1),:);
elseif lt(1)*lt(2)~=nb_comp
    error('mauvaise dimension du parametre interne');
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

%nouvelle implementation issue de Lockwood 2010/2012
%calcul derivees premieres et seconde selon chaque dimension puis
%combinaison
if nb_out==1
    %reponse
    G=prod(pc,2);
elseif nb_out==2
    %reponse
    G=prod(pc,2);
    %calcul derivees premieres
    dk1=-12.*xx./long.^2+18.*sign(xx).*xx.^2./long.^3;
    dk2=-6.*sign(xx).*(1-td).^2./long;
    dk3=ev3;
    dk=dk1.*IX1+dk2.*IX2+dk3.*IX3;
    L=[ones(nb_pt,1) cumprod(pc(:,1:end-1),2)];
    U=cumprod(pc(:,end:-1:2),2);U=[U(:,end:-1:1) ones(nb_pt,1)];
    dG=L.*U.*dk;

elseif nb_out==3
    %reponse
    G=prod(pc,2);
    %calcul derivees premieres
    dk1=-12.*xx./long.^2+18.*sign(xx).*xx.^2./long.^3;
    dk2=-6.*sign(xx).*(1-td).^2./long;
    dk3=ev3;
    dk=dk1.*IX1+dk2.*IX2+dk3.*IX3;
  % signification U et L cf. Lockwood 2010
    L=[ones(nb_pt,1) cumprod(pc(:,1:end-1),2)];
    U=cumprod(pc(:,end:-1:2),2);U=[U(:,end:-1:1) ones(nb_pt,1)];
    LdU=L.*U;
    %derivees premieres
    dG=LdU.*dk;

    %calcul derivees secondes
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    ddk1=36./long.^3.*abs(xx)-12./long.^2;
    ddk2=12.*(1-td)./long.^2;
    ddk3=ev3;
    ddk=ddk1.*IX1+ddk2.*IX2+ddk3.*IX3;
    
    if nb_pt==1
        % si un seul point d'evaluation (sortie derivees secondes sous la
        % forme d'une matrice)
        % signification U, L et M cf. Lockwood 2010
        prd=dk'*dk;
        prd(1:nb_comp+1:nb_comp^2)=ddk;
        %
        %pc=[1 pc]; %correction pc pour prise en compte dimension 1
        if nb_comp>1;motif=[1 1];else motif=1;end
        mm=[motif pc(2:nb_comp-1)];
        
        M=mm(ones(nb_comp,1),:);
        M=triu(M,2)+tril(ones(nb_comp),1);
        M=cumprod(M,2);
        %
        LUMt=triu(L'*U.*M,1);
        LUM=LUMt+LUMt';
        LUM(1:nb_comp+1:nb_comp^2)=LdU;
        %derivees secondes
        ddG=LUM.*prd;
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
        if nb_comp>1;motif=[1 1];else motif=1;end
        mm=[motif 3:nb_comp];
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
        ddG=LUM.*prd;
    end
else
    error('Mauvais argument de sortie de la fonction cubicspline2');
end
