%fonction assurant la création du métamodèle de Krigeage
%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr


function krg=meta_krg(tirages,eval,meta)

ns=size(eval,1);

%création matrice de conception
nbt=1/2*(meta.deg+1)(meta.deg+2);
fc=zeros(nbt,ns);
fct=['reg_poly' meta.deg];
for ii=1:ns
    fc(:,ii)=feval(fct,tirages(ii,:));
end


%création matrice de corrélation
rc=zeros(ns);

for ii=1:ns
    for jj=1:ns
       rc(ii,jj)=feval(meta.corr,tirages(ii,:)-tirages(jj,:),meta.theta);
    end
end

%création matrice de régression
irc=inv(rc);
ft=fct';
ifct=inv(fct);
%ift=inv(ft);
%%attention à vérifier
beta=ifct*y;




end