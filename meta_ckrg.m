%fonction assurant la création du métamodèle de CoKrigeage
%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr


function krg=meta_ckrg(tirages,eval,grad,meta)

global rcc y
ns=size(eval,1);
dim=size(tirages,2);



%Normalisation
if meta.norm
    %calcul des moyennes et des écarts type
    moy_e=mean(eval);
    std_e=std(eval);
    moy_t=mean(tirages);
    std_t=std(tirages);
    
    %test pour vérification écart type
    ind=find(std_e==0);
    if ~isempty(ind)
        std_e(ind)=1;
    end
    ind=find(std_t==0);
    if ~isempty(ind)
        std_t(ind)=1;
    end
    
    %normalisation
    eval=(eval-repmat(moy_e,ns,1))./repmat(std_e,ns,1);
    size(repmat(moy_t,ns,1))
    size(tirages)
    tirages=(tirages-repmat(moy_t,ns,1))./repmat(std_t,ns,1);
    
    grad=grad.*repmat(std_t,ns,1)/std_e;
    
    
    %sauvegarde des calculs
    krg.norm.moy_eval=moy_e;
    krg.norm.std_eval=std_e;
    krg.norm.moy_tirages=moy_t;
    krg.norm.std_tirages=std_t;
    krg.norm.on=true;
else
    krg.norm.on=false;
end

%rangement gradient
der=zeros(dim*ns,1);
for ii=1:ns
    for jj=1:dim
        der(dim*ii-dim+jj)=grad(ii,jj);        
    end
end

%création du vecteur d'évaluation
y=vertcat(eval,der) ;


%création matrice de conception
nbt=1/2*(meta.deg+1)*(meta.deg+2);
fc=zeros(ns,nbt);
fct=['reg_poly' num2str(meta.deg,1)];
for ii=1:ns
    fc(ii,:)=feval(fct,tirages(ii,:));
end

tmpp=repmat(0,dim*ns,nbt);
fc=vertcat(fc,tmpp);
%fc
%%%création matrice de corrélation
%morceau de la matrice issu du krigeage
rc=zeros(ns);
rca=zeros(ns,dim*ns);
rci=zeros(dim*ns,dim*ns);

for ii=1:ns
    for jj=1:ns
        %morceau de la matrice issu du krigeage
        [ev,dev,ddev]=feval(meta.corr,tirages(ii,:)-tirages(jj,:),meta.theta);
        %[ev,dev]=feval(meta.corr,tirages(ii,:)-tirages(jj,:),meta.theta);
        rc(ii,jj)=ev;        
        
        %morceau de la matrice provenant du Cokrigeage
        rca(ii,dim*jj-dim+1:dim*jj)=-dev;        
        rci(dim*ii-dim+1:dim*ii,dim*jj-dim+1:dim*jj)=-ddev;       
    end
end

%Nouvelle matrice rc dans le cas du CoKrigeage
rcc=[rc rca;rca' rci];
%rcc
disp('conditionnement R');
disp(cond(rcc));
% %Factorisation Cholesky
% rcc
% %C=chol(rcc);
% C=rcc;
% 
% 
% %résolution du problème des moindres carrés
% C=C';
% ft=C\fc;
% 
% %factorisation QR
% [Q R]=qr(ft,0);
% 
% Yy=C\y;
% krg.beta=R\(Q'*Yy);
% krg.gamma=(Yy-ft*krg.beta)'/C;
% krg.beta
% krg.gamma=krg.gamma';



%création matrice de régression par moindres carrés
%irc=inv(rc);
ft=fc';
% disp('R')
% rcc
% disp('inverse R')
% inv(rcc)
block1=((ft/rcc)*fc);
block2=((ft/rcc)*y);
% ft
% ft/rcc 
% y
krg.beta=block1\block2;
%control=((ft/rcc)*fc)\(ft/rcc)
%global control

% disp('beta')
% disp(krg.beta);

%création de la matrice des facteurs de corrélation
krg.gamma=rcc\(y-fc.*krg.beta);
% disp('gamma')
% disp(krg.gamma);

krg.reg=fct;
krg.nbt=ns;
krg.dim=dim;
krg.corr=meta.corr;
krg.deg=meta.deg;
krg.theta=meta.theta;
krg.con=size(tirages,2);

end