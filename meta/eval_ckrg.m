%fonction assurant l'évaluation du métamodèle de krigeage
%L. LAURENT -- 11/05/2010 -- L. LAURENT

function [Z,GZ]=eval_ckrg(X,tirages,krg)


if nargout==2
    grad=true;
else
    grad=false;
end

dim_x=size(X,1);

%normalisation
if krg.norm.on
    X=(X-repmat(krg.norm.moy_tirages,dim_x,1))./repmat(krg.norm.std_tirages,dim_x,1);
    tirages=(tirages-repmat(krg.norm.moy_tirages,krg.nbt,1))./repmat(krg.norm.std_tirages,krg.nbt,1);
end

%calcul de l'évaluation du métamodèle au point considéré
%matrice de corrélation aux points d'évaluations et matrice de corrélation
%dérivée
rr=zeros(krg.nbt*(krg.dim+1),1);
if grad
    jr=zeros(krg.nbt*(krg.dim+1),krg.con);
end

%distance du point d'évaluation aux sites obtenus par DOE
X 
tirages
krg.dim
dist=repmat(X,krg.dim,1)-tirages;

if grad  %si calcul des gradients
    [ev,dev,ddev]=feval(krg.corr,dist,krg.theta);
    rr(ll)=ev;
    rr(krg.nbt+krg.dim*(ll-1)+1:krg.nbt+krg.dim*ll)=dev;
    jr(ll,:)=dev;
    
    jr(krg.nbt+krg.dim*(ll-1)+1:krg.nbt+krg.dim*ll,:)=ddev;
else %sinon       
    [ev,dev]=feval(krg.corr,tirages(ll,:)-X,krg.theta);
    rr(ll)=ev;
    rr(krg.nbt+krg.dim*(ll-1)+1:krg.nbt+krg.dim*ll)=dev;
end


%matrice de régression aux points d'évalutions
if grad    
    [ff,jf]=feval(krg.reg,X);
else
    ff=feval(krg.reg,X);
end

%évaluation du métamodèle au point X
%global rr
Z=ff*krg.beta+rr'*krg.gamma;

if grad 
    GZ=jf*krg.beta-jr'*krg.gamma;
end

%normalisation
if krg.norm.on
    Z=repmat(krg.norm.moy_eval,dim_x,1)+repmat(krg.norm.std_eval,dim_x,1).*Z;
    if grad
        GZ=repmat(krg.norm.std_eval,dim_x,1).*GZ'./repmat(krg.norm.std_tirages,dim_x,1);
        GZ=GZ';
    end
end