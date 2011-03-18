%fonction assurant l'evaluation du metamodele de krigeage
%L. LAURENT -- 11/05/2010 -- L. LAURENT
%modifs le 03/11/2010  (reecriture en vue d'accelerer)

function [Z,GZ,var]=eval_krg(U,tirages,krg)

%calcul ou non des gradients (en fonction du nombre de variables de sortie)
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
%vecteur de correlation aux points d'evaluations et vecteur de correlation
%derive
rr=zeros(krg.dim,1);
if grad
    jr=zeros(krg.dim,krg.con);
end

%distance du point d'evaluation aux sites obtenus par DOE
dist=repmat(X,krg.dim,1)-tirages;

if grad  %si calcul des gradients
    [rr,jr]=feval(krg.corr,dist,krg.para.val);
else %sinon
    rr=feval(krg.corr,dist,krg.para.val);
end

%matrice de regression aux points d'evaluations
if grad
    [ff,jf]=feval(krg.reg,X);
else
    ff=feval(krg.reg,X);
end


%evaluation du metamodele au point X
Z=ff*krg.beta+rr'*krg.gamma;

if grad 
%%verif en 2D+
    GZ=jf*krg.beta+jr'*krg.gamma;
end


%calcul de la variance de prediction (MSE) (Lophaven, Nielsen & Sondergaard
%2004)
if nargout ==3
     warning off all;
    rcrr=krg.rc \ rr;
    u=krg.ft*rcrr-ff';   
    var=krg.sig2*(ones(dim_x,1)+u'*((krg.ft*(krg.rc\krg.ft')) \ u) - rr'*rcrr);
    warning on all;

end

%normalisation
if krg.norm.on
    Z=repmat(krg.norm.moy_eval,dim_x,1)+krg.norm.std_eval.*Z;
    if grad
        GZ=krg.norm.std_eval.*GZ'./repmat(krg.norm.std_tirages,dim_x,1);
        GZ=GZ';
    end
end
