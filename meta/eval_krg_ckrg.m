%% Fonction assurant l'evaluation du metamodele de Krigeage ou de Cokrigeage
% L. LAURENT -- 15/12/2011 -- laurent@lmt.ens-cachan.fr

function [Z,GZ,var]=eval_krg_ckrg(U,donnees,tir_part)
% affichages warning ou non
aff_warning=false;
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
    tirages=donnees.in.tiragesn;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X=U(:)';    %correction (changement type d'element)
dim_x=size(X,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation
if donnees.norm.on
    infos.moy=donnees.norm.moy_tirages;
    infos.std=donnees.norm.std_tirages;
    
    X=norm_denorm(X,'norm',infos);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calcul de l'evaluation du metamodele au point considere
%définition des dimensions des matrices/vecteurs selon KRG et CKRG
if donnees.in.pres_grad
    tail_matvec=nb_val*(nb_var+1);
else
    tail_matvec=nb_val;
end

%vecteur de correlation aux points d'evaluations et vecteur de correlation
%derive
rr=zeros(tail_matvec,1);
if calc_grad
    jr=zeros(tail_matvec,nb_var);
end
%distance du point d'evaluation aux sites obtenus par DOE
dist=repmat(X,nb_val,1)-tirages;

%KRG/CKRG
if donnees.in.pres_grad
    if calc_grad  %si calcul des gradients
        [ev,dev,ddev]=feval(donnees.build.corr,dist,donnees.build.para.val);
        rr(1:nb_val)=ev;
        
        rr(nb_val+1:tail_matvec)=-reshape(dev',1,nb_val*nb_var);
        
        %derivee du vecteur de correlation aux points d'evaluations
        jr(1:nb_val,:)=dev;  % a debugger
        
        % derivees secondes
        mat_der=zeros(nb_var,nb_var*nb_val);
        for mm=1:nb_val
            mat_der(:,(mm-1)*nb_var+1:mm*nb_var)=ddev(:,:,mm);
        end
        jr(nb_val+1:tail_matvec,:)=-mat_der';
        
    else %sinon
        %a reecrire //!!\\
        [ev,dev]=feval(donnees.build.corr,dist,donnees.build.para.val);
        rr(1:nb_val)=ev;
        rr(nb_val+1:tail_matvec)=reshape(dev',1,nb_val*nb_var);
    end
else
    if calc_grad  %si calcul des gradients
        [rr,jr]=feval(donnees.build.corr,dist,donnees.build.para.val);
    else %sinon
        rr=feval(donnees.build.corr,dist,donnees.build.para.val);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%matrice de regression aux points d'evaluations
if calc_grad
    [ff,jf]=feval(donnees.build.fct_reg,X);
else
    ff=feval(donnees.build.fct_reg,X);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%evaluation du metamodele au point X
Z=ff*donnees.build.beta+rr'*donnees.build.gamma;
%Z=krg.beta+rr'*krg.gamma; (pour CKRG???)
if calc_grad
    %%verif en 2D+
    GZ=jf'*donnees.build.beta+jr'*donnees.build.gamma;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calcul de la variance de prediction (MSE) (Lophaven, Nielsen & Sondergaard
%2004)
if nargout ==3
    if ~aff_warning;warning off all;end
    rcrr=donnees.build.rcc \ rr;
    u=donnees.build.fct*rcrr-ff';
    var=donnees.build.sig2*(ones(dim_x,1)+u'*...
        ((donnees.build.fct*(donnees.build.rcc\donnees.build.fc)) \ u) - rr'*rcrr);
    if ~aff_warning;warning on all;end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation
if donnees.norm.on
    infos.moy=donnees.norm.moy_eval;
    infos.std=donnees.norm.std_eval;
    size(Z)
    Z=norm_denorm(Z,'denorm',infos);
    Z
    if calc_grad
        infos.std_e=donnees.norm.std_eval;
        infos.std_t=donnees.norm.std_tirages;
        GZ=norm_denorm_g(GZ','denorm',infos); clear infos
        GZ=GZ';
    end
end