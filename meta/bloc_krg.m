%% Construction des blocs du Krigeage
%%L. LAURENT -- 05/01/2011 -- laurent@lmt.ens-cachan.fr


function [lilog,krg]=bloc_krg(tiragesn,ns,fc,y,meta,std_e,theta)

if nargin==7
    meta.theta=theta;
end

%creation matrice de correlation
rc=zeros(ns);
for ii=1:ns
    for jj=1:ns
       rc(ii,jj)=feval(meta.corr,tiragesn(jj,:)-tiragesn(ii,:),meta.theta);      
    end
end

%conditionnement de la matrice de correlation
if nargin==6    %en phase de minimisation
    krg.cond=cond(rc);
    fprintf('Conditionnement R: %6.5d\n',krg.cond)
end

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
krg.fc=fc;
krg.y=y;
krg.dim=ns;
krg.corr=meta.corr;
krg.deg=meta.deg;
krg.theta=meta.theta;

%variance de prediction
sig2=1/size(rc,1)*((y-fc*krg.beta)'/rc)*(y-fc*krg.beta);
if meta.norm
    krg.sig2=sig2*std_e^2;
else
    krg.sig2=sig2;
end


%Maximum de vraisemblance
[krg.lilog,krg.li]=likelihood(rc,sig2);
lilog=krg.lilog;