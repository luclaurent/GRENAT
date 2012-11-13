%%fonction de correlation Matern (5/2)
%%L. LAURENT -- 23/01/2011 -- luc.laurent@ens-cachan.fr
%revision du 12/11/2012 (issue de Lockwood 2010)

function [corr,dcorr,ddcorr]=rf_matern52(xx,long)

%verification de la dimension de lalongueur de correlations
lt=size(long);
%nombre de points a  evaluer
nb_pt=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);
%nombre de sorties
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
td=-abs(xx)./long*sqrt(5);
etd=exp(td);
co=1-td+5*xx.^2./(3.*long.^2);
pc=co.*etd;

%nouvelle implementation issue de Lockwood 2010
%calcul derivees premieres et seconde selon chaque dimension puis
%combinaison
if nb_out==1
    %reponse
    corr=prod(pc,2);
elseif nb_out==2
    %reponse
    corr=prod(pc,2);
    %calcul derivees premieres
    %calcul derivees premieres
    dk=-(5./(3*long.^2).*xx+5*sqrt(5)./(3*long.^3).*xx.^2.*sign(xx)).*etd;
    L=[ones(nb_pt,1) cumprod(pc(:,1:end-1),2)];
    U=cumprod(pc(:,end:-1:2),2);U=[U(:,end:-1:1) ones(nb_pt,1)];
    dcorr=L.*U.*dk;
    
elseif nb_out==3
    corr=prod(pc,2);
    %calcul derivees premieres
    dk=-(5./(3*long.^2).*xx+5*sqrt(5)./(3*long.^3).*xx.^2.*sign(xx)).*etd;
    % signification U et L cf. Lockwood 2010
    L=[ones(nb_pt,1) cumprod(pc(:,1:end-1),2)];
    U=cumprod(pc(:,end:-1:2),2);U=[U(:,end:-1:1) ones(nb_pt,1)];
    LdU=L.*U;
    %derivees premieres
    dcorr=LdU.*dk;
    
    %calcul derivees secondes
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    ddk=(-5./(3*long.^2)-5*sqrt(5)./(3*long.^3).*abs(xx)-25./(3*long.^4).*xx.^2).*etd;
    
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
        ddcorr=LUM.*prd;        
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
        ddcorr=LUM.*prd;
    end
else
    error('Mauvais argument de sortie de la fonction corr_matern52');
end