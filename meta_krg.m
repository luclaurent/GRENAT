%fonction assurant la création du métamodèle de Krigeage
%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr


function krg=meta_krg(tirages,eval,meta)

ns=size(eval,1);

%évaluation aux points de l'espace de conception
y=eval;

%création matrice de conception
nbt=1/2*(meta.deg+1)*(meta.deg+2);
fc=zeros(ns,nbt);
fct=['reg_poly' num2str(meta.deg,1)];
for ii=1:ns
    fc(ii,:)=feval(fct,tirages(ii,:));
end
%création matrice de corrélation
rc=zeros(ns);

for ii=1:ns
    for jj=1:ns
       rc(ii,jj)=feval(meta.corr,tirages(ii,:)-tirages(jj,:),meta.theta,'e');
    end
end

%création matrice de régression par moindres carrés
%irc=inv(rc);
ft=fc';


krg.beta=((ft/rc)*fc)\((ft/rc)*y);

%création de la matrice des facteurs de corrélation
krg.gamma=rc\(y-fc*krg.beta);

krg.reg=fct;
krg.dim=ns;
krg.corr=meta.corr;
krg.deg=meta.deg;
krg.theta=meta.theta;
krg.con=size(tirages,2);

end