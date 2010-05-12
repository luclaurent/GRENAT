%fonction assurant la création du métamodèle de CoKrigeage
%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr


function krg=meta_ckrg(tirages,eval,grad,meta)

ns=size(eval,1);


%rangement gradient
tmp=zeros(2*ns,1);
for ii=1:ns
    tmp(2*ii-1)=grad(ii,1);
    tmp(2*ii)=grad(ii,2);
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

tmpp=repmat(0,2*ns,nbt);
fc=vertcat(fc,tmpp);
%création matrice de corrélation
rc=zeros(ns);

for ii=1:ns
    for jj=1:ns
       rc(ii,jj)=feval(meta.corr,tirages(ii,:)-tirages(jj,:),meta.theta);
    end
end

%création matrice de régression par moindres carrés
%irc=inv(rc);
ft=fc';
size(y)
size(fc);
block1=((ft/rc)*fc);
block2=((ft/rc)*y);
krg.beta=block1\block2;


%création de la matrice des facteurs de corrélation
krg.gamma=rc\(y-fc*krg.beta);

krg.reg=fct;
krg.dim=ns;
krg.corr=meta.corr;
krg.deg=meta.deg;
krg.theta=meta.theta;
krg.con=size(tirages,2);

end