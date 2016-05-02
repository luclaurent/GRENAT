%% Fonction: Matern
%% L. LAURENT -- 06/02/2013 (r: 31/08/2015)-- luc.laurent@cnam.fr

%parametres possibles nd+1 (nd: portees et 1: regularite)

function [G,dG,ddG]=matern(xx,para,nuv)

%nombre de sorties
nb_out=nargout;
%mode demo
demo=false;
moddemo=1;
if nb_out==0
    if moddemo==1
        nb_s_demo=300;
        xx=linspace(-5,5,nb_s_demo);
        xx=xx';
        parad=[5/2 1];
    elseif moddemo==2
        nb_s_demo=50;
        xx=linspace(-5,5,nb_s_demo);
        [X,Y]=meshgrid(xx);
        xx=[X(:) Y(:)];
        parad=[5/2 1 0.9];
    end
    if nargin==0
        para=parad;
    end
    demo=true;
    nb_out=3;
end

%nombre de points a evaluer
nb_pt=size(xx,1);
%nombre de composantes
nb_comp=size(xx,2);
%verification de la dimension du parametre interne
lt=numel(para);
if nargin==3
    %regularite
    nu=nuv;
    if lt~=1&&lt~=nb_comp
        error(['Mauvais nombre de parametres (' mfilename '.m)']);
    end
    %portees
    long=para;
else
    %regularite
    nu=para(1);
    %portees
    long=para(2:end);
    if lt~=2&&lt~=nb_comp+1
        error(['Mauvais nombre de parametres (' mfilename '.m)']);
    end
end
%Le parametre interne est defini pour toutes les composantes de xx
if lt-1==1
    long = long*ones(nb_pt,nb_comp);
elseif lt-1==nb_comp
    long = long(ones(nb_pt,1),:);
end

%fonctions utiles
% sqrt(2*nu)*abs(x)/long
nx=@(nu,ll,xx) sqrt(2*nu).*abs(xx)./ll;
% derivee premiere
dnx=@(nu,ll,xx) sqrt(2*nu).*sign(xx)./ll;
% x^u*besselk
xbessel=@(nu,xx) xx.^nu.*besselk(nu,xx);
%derivee premiere de la fonction precedente
dxbessel=@(nu,xx) -xx.^nu.*besselk(nu-1,xx);
%derivee seconde de la fonction
ddxbessel=@(nu,xx) -xx.^(nu-1).*besselk(nu-1,xx)+xx.^nu.*besselk(nu-2,xx);

%calcul de la valeur de la fonction au point xx
coef_s=2^(1-nu)/gamma(nu);
xx_n=nx(nu,long,xx);
pc=coef_s.*xbessel(nu,xx_n);

%on s'assure que l'on peut bien faire le calcul (pb en zero)
II=abs(xx)<1e-50;
pc(II)=1;

%nouvelle implementation issue de Lockwood 2010/2012
%calcul derivees premieres et seconde selon chaque dimension puis
%combinaison
G=prod(pc,2);

%dérivées premieres
if nb_out>1
    %calcul derivees premieres
    dxx_n=dnx(nu,long,xx);
    dk=coef_s.*dxx_n.*dxbessel(nu,xx_n);
    %correction en 0
    dk(II)=0;
    % signification U et L cf. Lockwood 2010
    L=[ones(nb_pt,1) cumprod(pc(:,1:end-1),2)];
    U=cumprod(pc(:,end:-1:2),2);U=[U(:,end:-1:1) ones(nb_pt,1)];
    LdU=L.*U;
    %derivees premieres
    dG=LdU.*dk;
end

%dérivées secondes
if nb_out>2
    %calcul derivees secondes
    %suivant la taille de l'evaluation demandee on stocke les derivees
    %secondes de manieres differentes
    ddk=coef_s*dxx_n.^2.*ddxbessel(nu,xx_n);
    %correction en 0
    %vdp=-(2^(2-nu))*(2-nu)*gamma(nu-1)/gamma(nu)./long(II).^2;
    vdp=-nu*gamma(nu-1)/gamma(nu)./long(II).^2;
    ddk(II)=vdp;
    
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
end

if nb_out>3
    error(['Mauvais nombre d''arguments de sortie de la fonction (' mfilename '.m)']);
end
%figure en mode demo
if demo
    figure
    if moddemo==1
        plot(xx,G,'r','LineWidth',2)
        hold on
        plot(xx,dG,'b','LineWidth',2)
        ddG=vertcat(ddG(:));
        plot(xx,ddG,'k','LineWidth',2)
        hold off
        ax = gca;
        ax.XAxisLocation = 'origin';
        ax.YAxisLocation = 'origin';
        legend('h(r)','f''(r)','f''''(r)')
    elseif moddemo==2
        subplot(231)
        Gp=zeros(nb_s_demo);
        Gp(:)=G;
        surfc(X,Y,Gp)
        title('f(x,y)')
        subplot(232)
        Gp(:)=dG(:,1);
        surfc(X,Y,Gp)
        title('f''(x,y) (x)')
        subplot(233)
        Gp(:)=dG(:,2);
        surfc(X,Y,Gp)
        title('f''(x,y) (y)')
        subplot(234)
        Gp(:)=vertcat(ddG(1,1,:));
        surfc(X,Y,Gp)
        title('f''''(x,y) (x)')
        subplot(235)
        Gp(:)=vertcat(ddG(1,2,:));
        surfc(X,Y,Gp)
        title('f''''(x,y) (x,y)')
        subplot(236)
        Gp(:)=vertcat(ddG(2,2,:));
        surfc(X,Y,Gp)
        title('f''''(x,y) (y)')
    end
end
end
