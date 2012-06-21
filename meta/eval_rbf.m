%%fonction permettant d'evaluer le metamodele RBF en un ensemble de pts donnes
% RBF: sans gradient
% HBRF: avec gradients

%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 15/03/2010 reprise le 20/01/2012

function [Z,GZ,variance,details]=eval_rbf(U,data,tir_part)
% affichages warning ou non
aff_warning=false;
%Declaration des variables
nb_val=data.in.nb_val;
nb_var=data.in.nb_var;

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
    tirages=data.in.tiragesn;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X=U(:)';    %correction (changement type d'element)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation
if data.norm.on&&~isempty(data.norm.moy_tirages)
    infos.moy=data.norm.moy_tirages;
    infos.std=data.norm.std_tirages;
    X=norm_denorm(X,'norm',infos);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calcul de l'evaluation du metamodele au point considere
%definition des dimensions des matrices/vecteurs selon RBF et HBRBF
if data.in.pres_grad
    tail_matvec=nb_val*(nb_var+1);
else
    tail_matvec=nb_val;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%vecteur de correlation aux points d'evaluations et vecteur de correlation
%derive
if calc_grad
    dP=zeros(tail_matvec,nb_var);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%distance du point d'evaluation aux sites obtenus par DOE
dist=repmat(X,nb_val,1)-tirages;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RBF/HBRBF
if data.in.pres_grad
    if calc_grad  %si calcul des gradients
        %evaluation de la fonction de base radiale
        [ev,dev,ddev]=feval(data.build.fct,dist,data.build.para.val);
        %intercallage reponses et gradients
        %P=[F1 F2 ... Fn dF1/dx1 dF1/dx2 ... dF1/dxp dF2/dx1 dF2/dx2 ...dFn/dxp]
        P=[ev' reshape(dev',1,nb_val*nb_var)];
        
        %P=[ev;dda(:)];
        %intercallage derivees premieres et secondes
        %dP=[(dF1/dx1 dF1/dx2 ... dF1/dxp)' (dF2/dx1 dF2/dx2 ...dFn/dxp)' ]
        %dP=horzcat(-dda,reshape(ddev,nb_var,[]));
        %derivee du vecteur de correlation aux points d'evaluations
        dP=[dev' reshape(ddev,nb_var,[])];
        %si donnees manquantes
        if data.manq.eval.on
            P(data.manq.eval.ix_manq)=[];
            dP(:,data.manq.eval.ix_manq)=[];
        end
        
        %si donnees manquantes
        if data.manq.grad.on
            rep_ev=data.in.nb_val-data.manq.eval.nb;
            P(rep_ev+data.manq.grad.ixt_manq_line)=[];
            dP(:,rep_ev+data.manq.grad.ixt_manq_line)=[];
        end
    else %sinon
        %evaluation de la fonction de base radiale
        [ev,dev]=feval(data.build.fct,dist,data.build.para.val);
        %intercallage reponses et gradients
        %P=[F1 F2 ... Fn dF1/dx1 dF1/dx2 ... dF1/dxp dF2/dx1 dF2/dx2 ...dFn/dxp]
        P=[ev' reshape(dev',1,nb_val*nb_var)];
        %si donnees manquantes
        if data.manq.eval.on
            P(data.manq.eval.ix_manq)=[];
        end
    end
else
    if calc_grad  %si calcul des gradients
        [P,dP]=feval(data.build.fct,dist,data.build.para.val);P=P';dP=dP';
    else %sinon
        P=feval(data.build.fct,dist,data.build.para.val);P=P';
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Evaluation du metamodele au point X
Z=data.build.w'*P';

if calc_grad
    GZ=dP*data.build.w;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calcul de la variance de prediction (Bompard 2011,Sobester 2005, Gibbs 1997)
if nargout >=3
    if ~aff_warning;warning off all;end
    variance=1-P*(data.build.KK\P');
    if ~aff_warning;warning on all;end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation
if data.norm.on&&~isempty(data.norm.moy_tirages)
    infos.moy=data.norm.moy_eval;
    infos.std=data.norm.std_eval;
    Z=norm_denorm(Z,'denorm',infos);
    if calc_grad
        infos.std_e=data.norm.std_eval;
        infos.std_t=data.norm.std_tirages;
        GZ=norm_denorm_g(GZ','denorm',infos); clear infos
        GZ=GZ';
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calcul crit�re enrichissement
explor=[];
exploit=[];
wei=[];
ei=[];
if data.enrich.on&&exist('variance','var')
    %reponse mini
    eval_min=min(data.in.eval);
    %calcul crit�res enrichissement
    [ei,wei,gei,lcb,explor,exploit]=crit_enrich(eval_min,Z,variance,data.enrich);
end

%extraction d�tails
if nargout==4
    if ~isempty(explor);details.enrich.explor=explor;end
    if ~isempty(exploit);details.enrich.exploit=exploit;end
    if ~isempty(ei);details.enrich.ei=ei;end
    if ~isempty(wei);details.enrich.wei=wei;end
    if ~isempty(gei);details.enrich.gei=gei;end
    if ~isempty(lcb);details.enrich.lcb=lcb;end
end
end