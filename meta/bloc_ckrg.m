%% Construction des blocs du CoKrigeage
%%L. LAURENT -- 07/01/2011 -- laurent@lmt.ens-cachan.fr

function [lilog,krg]=bloc_ckrg(tiragesn,ns,fc,y,meta,std_e,para)

if nargin==7
    meta.para.val=para;
end

%dimension du pb (nb de variables de conception)
dim=size(tiragesn,2);

%%%creation matrice de correlation
%morceau de la matrice issu du krigeage
rc=zeros(ns);
rca=zeros(ns,dim*ns);
rci=zeros(dim*ns,dim*ns);

for ii=1:ns
    for jj=1:ns
        %morceau de la matrice issue du krigeage
        
        [ev,dev,ddev]=feval(meta.corr,tiragesn(ii,:)-tiragesn(jj,:),meta.para.val);
       
        rc(ii,jj)=ev;        
                
        %morceau de la matrice provenant du Cokrigeage
        rca(ii,dim*jj-dim+1:dim*jj)=-dev;
        
        %matrice des derivees secondes
        rci(dim*ii-dim+1:dim*ii,dim*jj-dim+1:dim*jj)=-ddev; 
       
   end
end

%Nouvelle matrice rc dans le cas du CoKrigeage
rcc=[rc rca;rca' rci];

%amelioration du conditionnement de la matrice de corr�lation
if meta.recond
    rcc=rcc+10^-4*eye(size(rcc));
end
%conditionnement de la matrice de correlation
if nargin==6    %en phase de minimisation
    krg.cond=cond(rcc);
    fprintf('Conditionnement R: %6.5d\n',krg.cond)
end

%calcul de beta
ft=fc';
block1=((ft/rcc)*fc);
block2=((ft/rcc)*y);
krg.beta=block1\block2;


%creation de la matrice des facteurs de correlation
krg.gamma=rcc\(y-fc*krg.beta);


%calcul de la variance de prediction
sig2=1/size(rcc,1)*((y-fc*krg.beta)'/rcc)*(y-fc*krg.beta);
if meta.norm
    krg.sig2=sig2*std_e^2;
else
    krg.sig2=sig2;
end


%Maximum de vraisemblance
[krg.lilog,krg.li]=likelihood(rcc,sig2);
lilog=krg.lilog

%sauvegarde des informations
krg.rcc=rcc;
krg.ft=ft;

