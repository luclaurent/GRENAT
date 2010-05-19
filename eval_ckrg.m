%fonction assurant l'évaluation du métamodèle de krigeage
%L. LAURENT -- 11/05/2010 -- L. LAURENT

function [Z,GZ]=eval_ckrg(X,tirages,krg)

if nargout==2
    grad=true;
else
    grad=false;
end

%calcul de l'évaluation du métamodèle au point considéré
%matrice de corrélation aux points d'évaluations et matrice de corrélation
%dérivée
rr=zeros(krg.nbt*(krg.dim+1),1);
if grad
    jr=zeros(krg.dim,krg.con);
end

for ll=1:krg.dim
   if grad  %si calcul des gradients
        [rr(ll),jr(ll,:)]=feval(krg.corr,tirages(ll,:)-X,krg.theta);
   else %sinon
        [ev,dev]=feval(krg.corr,tirages(ll,:)-X,krg.theta);
        rr(ll)=ev;
        rr(krg.dim*(ll-1)+1:krg.dim*ll)=dev;
   end
end

%matrice de régression aux points d'évalutions
nbt=1/2*(krg.deg+1)*(krg.deg+2);
ff=zeros(nbt,1);
if grad
    jf=zeros(nbt,krg.con);
    [ff,jf]=feval(krg.reg,X);
else
    ff=feval(krg.reg,X);
end

%évaluation du métamodèle au point X
Z=ff*krg.beta+rr'*krg.gamma;
if grad 
    GZ=jf*krg.beta+jr'*krg.gamma;
end