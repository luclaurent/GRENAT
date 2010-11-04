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
    tirages=(tirages-repmat(krg.norm.moy_tirages,krg.dim,1))./repmat(krg.norm.std_tirages,krg.dim,1);
end

%calcul de l'évaluation du métamodèle au point considéré
%vecteur de corrélation aux points d'évaluations et matrice de corrélation
%dérivée
rr=zeros(krg.dim*(krg.con+1),1);
if grad
    jr=zeros(krg.dim*(krg.con+1),krg.con);
end

%distance du point d'évaluation aux sites obtenus par DOE

dist=repmat(X,krg.dim,1)-tirages;

if grad  %si calcul des gradients
    [ev,dev,ddev]=feval(krg.corr,dist,krg.theta);
    rr(1:krg.dim)=ev;        
    rr(krg.dim+1:krg.dim*(krg.con+1))=reshape(dev',1,krg.dim*krg.con);
       
    %dérivée du vecteur de corrélation aux points d'évaluations
    jr(1:krg.dim,:)=dev;
       
    
     %reconditionnement dérivées secondes     
     mat_der=zeros(krg.dim*krg.con,krg.con);
    
     for mm=1:krg.dim
         ders=diag(ddev(mm,1:krg.con));
        itero=1;
        for ll=1:(krg.con-1)
            iter=krg.con-ll;
            sto=ddev(mm,krg.con+itero:krg.con+iter);
            ders(ll+1:krg.con,ll)=sto;
            ders(ll,ll+1:krg.con)=sto';
            itero=iter;
        end
        mat_der((mm-1)*krg.con+1:(mm-1)*krg.con+krg.con,:)=ders;
     end
        
    jr(krg.dim+1:krg.dim*(1+krg.con),:)=mat_der;
  
else %sinon       
    [ev,dev]=feval(krg.corr,dist,krg.theta);
    rr(1:krg.dim)=ev;
    rr(krg.dim+1:krg.dim*(krg.con+1)+1)=dev;
end


%matrice de régression aux points d'évalutions
if grad    
    [ff,jf]=feval(krg.reg,X);
else
    ff=feval(krg.reg,X);
end

%évaluation du métamodèle au point X

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