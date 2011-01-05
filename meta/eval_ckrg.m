%fonction assurant l'evaluation du metamodele de krigeage
%L. LAURENT -- 11/05/2010 -- L. LAURENT

function [Z,GZ,var]=eval_ckrg(U,tirages,krg)


if nargout>=2
    grad=true;
else
    grad=false;
end

X=U(:)';    %correction (changement type d'element)
dim_x=size(X,1);

%normalisation
if krg.norm.on
    mat_moyt=repmat(krg.norm.moy_tirages,dim_x,1);
    mat_stdt=repmat(krg.norm.std_tirages,dim_x,1);
    X=(X-mat_moyt)./mat_stdt;
    tirages=(tirages-repmat(krg.norm.moy_tirages,krg.dim,1))./...
        repmat(krg.norm.std_tirages,krg.dim,1);
end

%calcul de l'evaluation du metamodele au point considere
%vecteur de correlation aux points d'evaluations et matrice de correlation
%derivee
rr=zeros(krg.dim*(krg.con+1),1);
if grad
    jr=zeros(krg.dim*(krg.con+1),krg.con);
end

%distance du point d'evaluation aux sites obtenus par DOE
dist=repmat(X,krg.dim,1)-tirages;

if grad  %si calcul des gradients
    [ev,dev,ddev]=feval(krg.corr,dist,krg.theta);
    rr(1:krg.dim)=ev;  
    rr(krg.dim+1:krg.dim*(krg.con+1))=-reshape(dev',1,krg.dim*krg.con);

    %derivee du vecteur de correlation aux points d'evaluations
    jr(1:krg.dim,:)=dev;

     % derivees secondes     
     mat_der=zeros(krg.con,krg.dim*krg.con);
    
     for mm=1:krg.dim
        mat_der(:,(mm-1)*krg.con+1:(mm-1)*krg.con+krg.con,:)=ddev(:,:,mm);
     end
        
    jr(krg.dim+1:krg.dim*(1+krg.con),:)=-mat_der';
   
else %sinon
    %a reecrire //!!\\
    [ev,dev]=feval(krg.corr,dist,krg.theta);
    rr(1:krg.dim)=ev;
    rr(krg.dim+1:krg.dim*(krg.con+1))=dev;
end


%matrice de regression aux points d'evaluations
if grad    
    [ff,jf]=feval(krg.reg,X);
else
    ff=feval(krg.reg,X);
end

%evaluation du metamodele au point X
%a reecrire pour passage au krigeage universel
Z=krg.beta+rr'*krg.gamma;

if grad 
    GZ=jf'.*krg.beta+jr'*krg.gamma;
end

%calcul de la variance de prediction (MSE) (Koelher & Owen 1996)
if nargout ==3
    rcrr=krg.rcc \ rr;
    u=krg.ft*rcrr-ff';
    var=krg.sig2*(ones(dim_x,1)+u'*((krg.ft*(krg.rcc\krg.ft')) \ u)...
        - rr'*rcrr);
end

%normalisation
if krg.norm.on
    Z=repmat(krg.norm.moy_eval,dim_x,1)+krg.norm.std_eval.*Z;
    if grad
        GZ=krg.norm.std_eval.*GZ'./repmat(krg.norm.std_tirages,dim_x,1);
        GZ=GZ';
    end
end


