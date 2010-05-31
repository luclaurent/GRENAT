%fonction assurant l'évaluation du métamodèle de krigeage
%L. LAURENT -- 11/05/2010 -- L. LAURENT

function [Z,GZ]=eval_krg(X,tirages,krg)

if nargout==2
    grad=true;
else
    grad=false;
end

dim_x=size(X,1);

%normalisation
if krg.norm.on
    X=(X-repmat(krg.norm.moy_tirages,dim_x,1))./repmat(krg.norm.std_tirages,dim_x,1);
    tirages=(tirages-repmat(krg.norm.moy_tirages,krg.dim,1))./repmat(krg.norm.std_tirages,krg.dim,1);
    
    %X=(X-repmat(krg.norm.moy_tirages,dim_x,1))./repmat(2*krg.norm.std_tirages,dim_x,1)+repmat(0.5,dim_x,1);
    %tirages=(tirages-repmat(krg.norm.moy_tirages,krg.dim,1))./repmat(2*krg.norm.std_tirages,krg.dim,1)+repmat(0.5,krg.dim,1);
    %X=X/krg.dive;
    %tirages=tirages/krg.divt;
end

%calcul de l'évaluation du métamodèle au point considéré
%matrice de corrélation aux points d'évaluations et matrice de corrélation
%dérivée
rr=zeros(krg.dim,1);
if grad
    jr=zeros(krg.dim,krg.con);
end

for ll=1:krg.dim
   if grad  %si calcul des gradients
        [rr(ll),jr(ll,:)]=feval(krg.corr,tirages(ll,:)-X,krg.theta);
   else %sinon
        rr(ll)=feval(krg.corr,tirages(ll,:)-X,krg.theta);
   end
end

%matrice de régression aux points d'évalutions
if grad
    [ff,jf]=feval(krg.reg,X);
else
    ff=feval(krg.reg,X);
end

%évaluation du métamodèle au point X
Z=ff*krg.beta+rr'*krg.gamma;

%+rr'*krg.gamma;
if grad 
    GZ=jf*krg.beta+jr'*krg.gamma;
end

%normalisation
if krg.norm.on
Z=repmat(krg.norm.moy_eval,dim_x,1)+repmat(krg.norm.std_eval,dim_x,1).*Z;
%Z=repmat(krg.norm.moy_eval,dim_x,1)+repmat(2*krg.norm.std_eval,dim_x,1).*(Z-repmat(0.5,dim_x,1));
end