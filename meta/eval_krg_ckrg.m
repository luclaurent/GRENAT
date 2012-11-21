%% Fonction assurant l'evaluation du metamodele de Krigeage ou de Cokrigeage
% L. LAURENT -- 15/12/2011 -- laurent@lmt.ens-cachan.fr

function [Z,GZ,variance,details]=eval_krg_ckrg(U,donnees,tir_part)
% affichages warning ou non
aff_warning=false;
%D�claration des variables
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
%d�finition des dimensions des matrices/vecteurs selon KRG et CKRG
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
        
        %si donnees manquantes
        if donnees.manq.eval.on
            rr(donnees.manq.eval.ix_manq)=[];
            jr(donnees.manq.eval.ix_manq,:)=[];
        end
        
        %si donnees manquantes
        if donnees.manq.grad.on
            rep_ev=donnees.in.nb_val-donnees.manq.eval.nb;
            rr(rep_ev+donnees.manq.grad.ixt_manq_line)=[];
            jr(rep_ev+donnees.manq.grad.ixt_manq_line,:)=[];
        end
        
    else %sinon
        %a reecrire //!!\\
        [ev,dev]=feval(donnees.build.corr,dist,donnees.build.para.val);
        rr(1:nb_val)=ev;
        rr(nb_val+1:tail_matvec)=-reshape(dev',1,nb_val*nb_var);
        %si donnees manquantes
        if donnees.manq.eval.on
            rr(donnees.manq.eval.ix_manq)=[];
            %si donnees manquantes
            if donnees.manq.grad.on
                rep_ev=donnees.in.nb_val-donnees.manq.eval.nb;
                rr(rep_ev+donnees.manq.grad.ixt_manq_line)=[];
            end
        end
    end
else
    if calc_grad  %si calcul des gradients
        [rr,jr]=feval(donnees.build.corr,dist,donnees.build.para.val);
            else %sinon
        rr=feval(donnees.build.corr,dist,donnees.build.para.val);
    end
    %si donnees manquantes
    if donnees.manq.eval.on
        rr(donnees.manq.eval.ix_manq)=[];
        jr(donnees.manq.eval.ix_manq,:)=[];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%matrice de regression aux points d'evaluations
if calc_grad
    [ff,~,jf,~]=feval(donnees.build.fct_reg,X);
    jf=vertcat(jf{:});        
else
    ff=feval(donnees.build.fct_reg,X);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%evaluation du metamodele au point X
Z_reg=ff*donnees.build.beta;
Z_sto=rr'*donnees.build.gamma;
Z=Z_reg+Z_sto;
if calc_grad
    %%verif en 2D+
    GZ_reg=jf*donnees.build.beta;
    GZ_sto=jr'*donnees.build.gamma;
    GZ=GZ_reg+GZ_sto;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calcul de la variance de prediction (MSE) (Lophaven, Nielsen & Sondergaard
%2004 / Marcelet 2008 / Chauvet 1999)
if nargout >=3
    if ~aff_warning;warning off all;end
    %en fonction de la factorisation
    switch donnees.build.fact_rcc
        case 'QR'
           Qrr=donnees.build.Qtrcc*rr;
            u=donnees.build.fcR*Qrr-ff';
            variance=donnees.build.sig2*(ones(dim_x,1)-(rr'/donnees.build.Rrcc)*Qrr+...
                u'*donnees.build.fcCfct*u);
           
        case 'LU'
            Lrr=donnees.build.Lrcc\rr;
            u=donnees.build.fcU*Lrr-ff';
            variance=donnees.build.sig2*(ones(dim_x,1)-(rr'/donnees.build.Urcc)*Lrr+...
                u'*donnees.build.fcCfct*u);
        case 'LL'
            Lrr=donnees.build.Lrcc\rr;
            u=donnees.build.fcL*Lrr-ff';
            variance=donnees.build.sig2*(ones(dim_x,1)-(rr'/donnees.build.Ltrcc)*Lrr+...
                u'*donnees.build.fcCfct*u);            
        otherwise
            rcrr=donnees.build.rcc \ rr;
            u=donnees.build.fc*rcrr-ff';
            variance=donnees.build.sig2*(ones(dim_x,1)+u'/donnees.build.fcCfct*u - rr'*rcrr);
    end
    if ~aff_warning;warning on all;end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation
if donnees.norm.on
    infos.moy=donnees.norm.moy_eval;
    infos.std=donnees.norm.std_eval;
    Z=norm_denorm(Z,'denorm',infos);
    if nargout==4        
        Z_reg=norm_denorm(Z_reg,'denorm',infos);       
        Z_sto=norm_denorm(Z_sto,'denorm',infos);
    end
    if calc_grad
        infos.std_e=donnees.norm.std_eval;
        infos.std_t=donnees.norm.std_tirages;
        GZ=norm_denorm_g(GZ','denorm',infos);
        GZ=GZ';
        if nargout==4
            GZ_reg=norm_denorm(GZ_reg','denorm',infos)';
            GZ_sto=norm_denorm(GZ_sto','denorm',infos)';
        end
        clear infos
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calcul critere enrichissement
explor_EI=[];
exploit_EI=[];
ei=[];
wei=[];
gei=[];
lcb=[];
if donnees.enrich.on&&exist('variance','var')
    %reponse mini
    eval_min=min(donnees.in.eval);
    %calcul criteres enrichissement
    [ei,wei,gei,lcb,exploit_EI,explor_EI]=crit_enrich(eval_min,Z,variance,donnees.enrich);
end

%extraction details
if nargout==4
    details.Z_reg=Z_reg;
    details.Z_sto=Z_sto;
    details.GZ_reg=GZ_reg;
    details.GZ_sto=GZ_sto;
    if ~isempty(explor_EI);details.enrich.explor_EI=explor_EI;end
    if ~isempty(exploit_EI);details.enrich.exploit_EI=exploit_EI;end
    if ~isempty(ei);details.enrich.ei=ei;end
    if ~isempty(wei);details.enrich.wei=wei;end
    if ~isempty(gei);details.enrich.gei=gei;end
    if ~isempty(lcb);details.enrich.lcb=lcb;end
end
end