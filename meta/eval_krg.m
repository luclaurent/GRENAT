%fonction assurant l'evaluation du metamodele de krigeage
%L. LAURENT -- 11/05/2010 -- L. LAURENT
%modifs le 03/11/2010  (reecriture en vue d'accélérer)

function [Z,GZ]=eval_krg(X,tirages,krg)

%calcul ou non des gradients (en fonction du nombre de variables de sortie)
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
%vecteur de corrélation aux points d'évaluations et vecteur de corrélation
%dérivé
rr=zeros(krg.dim,1);
if grad
    jr=zeros(krg.dim,krg.con);
end

%distance du point d'évaluation aux sites obtenus par DOE
dist=repmat(X,krg.dim,1)-tirages;

if grad  %si calcul des gradients
    [rr,jr]=feval(krg.corr,dist,krg.theta);
else %sinon
    rr=feval(krg.corr,dist,krg.theta);
end


%matrice de régression aux points d'évaluations
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
    if grad
        GZ=repmat(krg.norm.std_eval,dim_x,1).*GZ'./repmat(krg.norm.std_tirages,dim_x,1);
        GZ=GZ';
    end
end