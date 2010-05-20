%fonction assurant la création du métamodèle de CoKrigeage
%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr


function krg=meta_ckrg(tirages,eval,grad,meta)

global rcc
ns=size(eval,1);
dim=size(tirages,2);

%rangement gradient
tmp=zeros(dim*ns,1);
for ii=1:ns
    for jj=1:dim
        tmp(dim*ii-dim+jj)=grad(ii,jj);
        
    end
end

%évaluation aux points de l'espace de conception
y=vertcat(eval,tmp) ;


%création matrice de conception
nbt=1/2*(meta.deg+1)*(meta.deg+2);
fc=zeros(ns,nbt);
fct=['reg_poly' num2str(meta.deg,1)];
for ii=1:ns
    fc(ii,:)=feval(fct,tirages(ii,:));
end

tmpp=repmat(0,dim*ns,nbt);
fc=vertcat(fc,tmpp);

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
        rca(ii,dim*jj-dim+1:dim*jj)=dev;        
        rci(dim*ii-dim+1:dim*ii,dim*jj-dim+1:dim*jj)=ddev;       
    end
end

%Nouvelle matrice rc dans le cas du CoKrigeage
rcc=[rc rca;rca' rci];
rcc

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

block1=((ft/rcc)*fc);
block2=((ft/rcc)*y);
krg.beta=block1\block2;


%création de la matrice des facteurs de corrélation
krg.gamma=rcc\(y-fc*krg.beta);

krg.reg=fct;
krg.nbt=ns;
krg.dim=dim;
krg.corr=meta.corr;
krg.deg=meta.deg;
krg.theta=meta.theta;
krg.con=size(tirages,2);

end