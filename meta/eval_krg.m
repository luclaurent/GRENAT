%fonction assurant l'evaluation du metamodele de krigeage
%L. LAURENT -- 11/05/2010 -- L. LAURENT
%modifs le 03/11/2010  (reecriture en vue d'accelerer)
%modifs le 19/10/2011  (passage nD)

function [Z,GZ,var]=eval_krg(U,tirages,krg)

%calcul ou non des gradients (en fonction du nombre de variables de sortie)
if nargout>=2
    grad=true;
else
    grad=false;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 X=U(:)';    %correction (changement type d'element)
 dim_x=size(X,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation
if krg.norm.on
    infos.moy=krg.norm.moy_tirages;
    infos.std=krg.norm.std_tirages;
    X=norm_denorm(X,'norm',infos);
    tirages=norm_denorm(tirages,'norm',infos);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calcul de l'evaluation du metamodele au point considere
%vecteur de correlation aux points d'evaluations et vecteur de correlation
%derive
rr=zeros(krg.dim,1);
if grad
    jr=zeros(krg.dim,krg.con);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%distance du point d'evaluation aux sites obtenus par DOE
dist=repmat(X,krg.dim,1)-tirages;

if grad  %si calcul des gradients
    [rr,jr]=feval(krg.corr,dist,krg.para.val);
else %sinon
    rr=feval(krg.corr,dist,krg.para.val);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%matrice de regression aux points d'evaluations
if grad
    [ff,jf]=feval(krg.reg,X);
else
    ff=feval(krg.reg,X);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%evaluation du metamodele au point X
Z=ff*krg.beta+rr'*krg.gamma;

if grad 
%%verif en 2D+
    GZ=jf'*krg.beta+jr'*krg.gamma;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calcul de la variance de prediction (MSE) (Lophaven, Nielsen & Sondergaard
%2004)
if nargout ==3
     warning off all;
    rcrr=krg.rc \ rr;
    u=krg.ft*rcrr-ff';   
    var=krg.sig2*(ones(dim_x,1)+u'*((krg.ft*(krg.rc\krg.ft')) \ u) - rr'*rcrr);
    warning on all;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation
if krg.norm.on
    infos.moy=krg.norm.moy_eval;
    infos.std=krg.norm.std_eval;    
    Z=norm_denorm(Z,'denorm',infos);
    if grad
        infos.std_e=krg.norm.std_eval;
        infos.std_t=krg.norm.std_tirages;
        GZ=norm_denorm_g(GZ','denorm',infos); clear infos
        GZ=GZ';
    end
end
