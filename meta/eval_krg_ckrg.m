%% Fonction assurant l'evaluation du metamodele de Krigeage ou de Cokrigeage
% L. LAURENT -- 15/12/2011 -- laurent@lmt.ens-cachan.fr

function [Z,GZ,var]=eval_krg_ckrg(U,donnees)

%Déclaration des variables
nb_val=donnees.in.nb_val;
nb_var=donnees.in.nb_var;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calcul ou non des gradients (en fonction du nombre de variables de sortie)
if nargout>=2
    calc_grad=true;
else
    calc_grad=false;
end
% points de tirages particuliers
if nargin==3
    tirages=tir_part;
else
    tirages=krg.tirages;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 X=U(:)';    %correction (changement type d'element)
 dim_x=size(X,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation
if krg.norm.on
    infos.moy=donnees.norm.moy_tirages;
    infos.std=donnees.norm.std_tirages;
    X=norm_denorm(X,'norm',infos);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calcul de l'evaluation du metamodele au point considere
%vecteur de correlation aux points d'evaluations et vecteur de correlation
%derive
rr=zeros(krg.dim,1);
if calc_grad
    jr=zeros(krg.dim,krg.con);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calcul de l'evaluation du metamodele au point considere
%vecteur de correlation aux points d'evaluations et matrice de correlation
%derivee
rr=zeros(krg.dim*(krg.con+1),1);
if calc_grad
    jr=zeros(krg.dim*(krg.con+1),krg.con);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%distance du point d'evaluation aux sites obtenus par DOE
dist=repmat(X,krg.dim,1)-tirages;

if calc_grad  %si calcul des gradients
    [rr,jr]=feval(krg.corr,dist,krg.para.val);
else %sinon
    rr=feval(krg.corr,dist,krg.para.val);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%matrice de regression aux points d'evaluations
if calc_grad
    [ff,jf]=feval(krg.reg,X);
else
    ff=feval(krg.reg,X);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%evaluation du metamodele au point X
Z=ff*krg.beta+rr'*krg.gamma;

if calc_grad 
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
    if calc_grad
        infos.std_e=krg.norm.std_eval;
        infos.std_t=krg.norm.std_tirages;
        GZ=norm_denorm_g(GZ','denorm',infos); clear infos
        GZ=GZ';
    end
end

%%CKRG





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%distance du point d'evaluation aux sites obtenus par DOE
dist=repmat(X,krg.dim,1)-tirages;

if calc_grad  %si calcul des gradients
    [ev,dev,ddev]=feval(krg.corr,dist,krg.para.val);
    rr(1:krg.dim)=ev;  
    rr(krg.dim+1:krg.dim*(krg.con+1))=reshape(dev',1,krg.dim*krg.con);

    %derivee du vecteur de correlation aux points d'evaluations
    jr(1:krg.dim,:)=dev;  % a debugger

     % derivees secondes     
     mat_der=zeros(krg.con,krg.dim*krg.con);
    
     for mm=1:krg.dim
        mat_der(:,(mm-1)*krg.con+1:(mm-1)*krg.con+krg.con,:)=ddev(:,:,mm);
     end
        
    jr(krg.dim+1:krg.dim*(1+krg.con),:)=-mat_der';
   
else %sinon
    %a reecrire //!!\\
    [ev,dev]=feval(krg.corr,dist,krg.para.val);
    rr(1:krg.dim)=ev;
    rr(krg.dim+1:krg.dim*(krg.con+1))=dev;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%matrice de regression aux points d'evaluations
if calc_grad    
    [ff,jf]=feval(krg.reg,X);
else
    ff=feval(krg.reg,X);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%evaluation du metamodele au point X
%a reecrire pour passage au krigeage universel
Z=krg.beta+rr'*krg.gamma;

if calc_grad 
    GZ=jf'.*krg.beta+jr'*krg.gamma;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calcul de la variance de prediction (MSE) (Koelher & Owen 1996)
if nargout ==3
    warning off all
    rcrr=krg.rcc \ rr;
    u=krg.ft*rcrr-ff';
    var=krg.sig2*(ones(dim_x,1)+u'*((krg.ft*(krg.rcc\krg.ft')) \ u)...
        - rr'*rcrr);
    warning on all
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%denormalisation
if krg.norm.on
    infos.moy=krg.norm.moy_eval;
    infos.std=krg.norm.std_eval;    
    Z=norm_denorm(Z,'denorm',infos);
    if calc_grad
        infos.std_e=krg.norm.std_eval;
        infos.std_t=krg.norm.std_tirages;
        GZ=norm_denorm_g(GZ','denorm',infos); clear infos
        GZ=GZ';
    end
end



