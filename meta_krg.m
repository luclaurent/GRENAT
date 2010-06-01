
%fonction assurant la création du métamodèle de Krigeage
%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr


function krg=meta_krg(tirages,eval,meta)

ns=size(eval,1);
%Normalisation
if meta.norm
    disp('normalisation');
    moy_e=mean(eval);
    std_e=std(eval);
    moy_t=mean(tirages);
    std_t=std(tirages);

    %normalisation des valeur de la fonction objectif et des tirages
    eval=(eval-repmat(moy_e,ns,1))./repmat(std_e,ns,1);
    tirages=(tirages-repmat(moy_t,ns,1))./repmat(std_t,ns,1);
    
    %sauvegarde des données
    krg.norm.moy_eval=moy_e;
    krg.norm.std_eval=std_e;
    krg.norm.moy_tirages=moy_t;
    krg.norm.std_tirages=std_t;
    krg.norm.on=true;
else
    krg.norm.on=false;
end

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
       rc(ii,jj)=feval(meta.corr,tirages(jj,:)-tirages(ii,:),meta.theta);      
    end
end
disp('conditionnement R');
disp(cond(rc));

%calcul du coefficient beta
ft=fc';
block1=((ft/rc)*fc);
block2=((ft/rc)*y);
krg.beta=block1\block2;

%calcul du coefficient gamma
krg.gamma=rc\(y-fc*krg.beta);


%sauvegarde de données
krg.reg=fct;
krg.dim=ns;
krg.corr=meta.corr;
krg.deg=meta.deg;
krg.theta=meta.theta;
krg.con=size(tirages,2);

end