%%fonction de correlation Matern 
%%L. LAURENT -- 06/02/2013 -- luc.laurent@lecnam.net

%parametres possibles nd+1 (nd: portees et 1: regularite

function [corr,dcorr,ddcorr]=corr_matern(xx,para)

%nombre de points a evaluer
nb_pt=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);
%nombre de sorties
nb_out=nargout;
%verification de la dimension de la longueur de correlations
lt=numel(para);
if lt~=2||lt~=nb_comp+1
    error('Mauvais nombre de parametres corr_matern');
end
%regularite
nu=para(1);
%portees
long=para(2:end);
%La longueur de correlation est definie pour toutes les composantes de xx
if lt-1==1
    long = long*ones(nb_pt,nb_comp);
elseif lt-1==nb_comp
    long = long(ones(nb_pt,1),:);
end

%calcul de la valeur de la fonction au point xx
coef_m=2*nu^.5./long;
coef_s=nu./2^(nu-1)*gamma(nu);
xx_n=abs(xx)./long;
xx_pn=abs(xx).^(-nu);
%on s'assure que l'on peut bien faire le calcul (pb en zero)
II=xx_pn<1e50;
pc=ones(nb_pt,nb_comp);
bess_nu=besselmx(double('K'),nu,xx_n,0);
pc(II)=coef_m(II).^nu.*coef_s./xx_pn(II).*bess_nu(II);

%nouvelle implementation issue de Lockwood 2010/2012
%calcul derivees premieres et seconde selon chaque dimension puis
%combinaison
if nb_out==1
    corr=prod(pc,2);
elseif nb_out==2
    %reponse
    corr=prod(pc,2);
    %calcul derivees premieres
    dk=zeros(nb_pt,nb_comp);
    dk(II)=-coef_s.*coef_m(II).^(nu+1)./xx_pn(II).*...
        besselmx(double('K'),nu-1,xx_n(II),0).*sign(xx(II));
    L=[ones(nb_pt,1) cumprod(pc(:,1:end-1),2)];
    U=cumprod(pc(:,end:-1:2),2);U=[U(:,end:-1:1) ones(nb_pt,1)];
    dcorr=L.*U.*dk;

elseif nb_out==3
    %reponse
    corr=prod(pc,2);
    %calcul derivees premieres
    bess_num=besselmx(double('K'),nu-1,xx_n,0);
    dk=zeros(nb_pt,nb_comp);
    dk(II)=-coef_s.*coef_m(II).^(nu+1)./xx_pn(II).*...
        bess_num(II).*sign(xx(II));
  % signification U et L cf. Lockwood 2010
    L=[ones(nb_pt,1) cumprod(pc(:,1:end-1),2)];
    U=cumprod(pc(:,end:-1:2),2);U=[U(:,end:-1:1) ones(nb_pt,1)];
    LdU=L.*U;
    %derivees premieres
    dcorr=LdU.*dk;

    %calcul derivees secondes
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    ddk=-coef_s.*coef_m.^(nu+1).*(abs(xx).^(nu-1).*bess_num-...
        coef_m.*abs(xx).^nu.*besselmx(double('K'),nu-2,xx_n,0));
    
    -coef_s.*coef_m.^(nu+1).*(1-coef_m)
    
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
    error('Mauvais argument de sortie de la fonction corr_matern32');
end