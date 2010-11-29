
%fonction assurant la creation du metamodele de Krigeage
%L. LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr


function krg=meta_krg(tirages,eval,meta)

ns=size(eval,1);

%Normalisation
if meta.norm
    disp('Normalisation\n');
    moy_e=mean(eval);
    std_e=std(eval);
    moy_t=mean(tirages);
    std_t=std(tirages);

    %normalisation des valeur de la fonction objectif et des tirages
    eval=(eval-repmat(moy_e,ns,1))./repmat(std_e,ns,1);
    tirages=(tirages-repmat(moy_t,ns,1))./repmat(std_t,ns,1);
    
    %sauvegarde des donnees
    krg.norm.moy_eval=moy_e;
    krg.norm.std_eval=std_e;
    krg.norm.moy_tirages=moy_t;
    krg.norm.std_tirages=std_t;
    krg.norm.on=true;
else
    krg.norm.on=false;
end

%evaluation aux points de l'espace de conception
y=eval;

%creation matrice de conception
%(regression polynomiale)
nbt=(meta.deg+1)*(meta.deg+2)*1/2;
fc=zeros(ns,nbt);
fct=['reg_poly' num2str(meta.deg,1)];
for ii=1:ns
    fc(ii,:)=feval(fct,tirages(ii,:));
end

%creation matrice de correlation
rc=zeros(ns);
for ii=1:ns
    for jj=1:ns
       rc(ii,jj)=feval(meta.corr,tirages(jj,:)-tirages(ii,:),meta.theta);      
    end
end

%conditionnement de la matrice de correlation
krg.cond=cond(rc);
sprintf('Conditionnement R: %6.5d\n',krg.cond)

%calcul du coefficient beta
%%approche classique
 ft=fc';
 block1=((ft/rc)*fc);
 block2=((ft/rc)*y);
 krg.beta=block1\block2;
%approche factorisee
%attention cette factorisation n'est possible que sous condition
% %cholesky
% c=chol(rc);
% fcc=c\fc;
% %QR
% [qf,rf]=qr(fcc);
% yc=c\y;
% krg.beta=rf\(qf'*yc);

%calcul du coefficient gamma
krg.gamma=rc\(y-fc*krg.beta);


%sauvegarde de donnees
krg.rc=rc;
krg.ft=ft;
krg.reg=fct;
krg.dim=ns;
krg.corr=meta.corr;
krg.deg=meta.deg;
krg.theta=meta.theta;
krg.con=size(tirages,2);

%Maximum de vraisemblance
[krg.lilog,krg.li]=likelihood(rc,y,fc,krg.beta);

%écart type a denormaliser !!!!!!
krg.sig=1/size(rc,1)*(y-fc*krg.beta)'/rc*(y-fc*krg.beta);

end