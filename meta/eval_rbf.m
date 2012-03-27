%%fonction permettant d'evaluer le metamodele RBF en un ensemble de pts donnes
% RBF: sans gradient
% HBRF: avec gradients

%%L. LAURENT      luc.laurent@ens-cachan.fr
%% 15/03/2010 reprise le 20/01/2012

function [Z,GZ]=eval_rbf(U,donnees,tir_part)
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
%d�finition des dimensions des matrices/vecteurs selon RBF et HBRBF
if donnees.in.pres_grad
    tail_matvec=nb_val*(nb_var+1);
else
    tail_matvec=nb_val;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%vecteur de correlation aux points d'evaluations et vecteur de correlation
%derive
P=zeros(tail_matvec,1);
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
if donnees.in.pres_grad
    if calc_grad  %si calcul des gradients
        %evaluation de la fonction de base radiale
        [ev,dev,ddev]=feval(donnees.build.fct,dist,donnees.build.para.val);
        %[~,~,ddev]=feval(donnees.build.fct,-dist,donnees.build.para.val);
        %intercallage reponses et gradients
        %[P1 dP1/dx1 dP1/dx2 ... dP1/dxp P2 dP2/dx1 dP2/dx2 ...dPn/dxp]
        %conditionneme~nt evaluations
        comp=zeros(nb_val,nb_var);
        eva=[ev comp]';
        %conditionnement gradients
        comp=zeros(nb_val,1);
        deva=[comp dev]';
        %creation vecteur evaluations/gradients
        P=eva(:)+deva(:); 
        %creation vecteur derivees fonction base radiale (calcul gradients
        %du metamodele)
        dP=[];
        for ii=1:nb_val
            dP=vertcat(dP,dev(ii,:),ddev(:,:,ii));
        end

    else %sinon
        %evaluation de la fonction de base radiale
        [ev,dev]=feval(donnees.build.fct,dist,donnees.build.para.val);
        %intercallage reponses et gradients
        %[P1 dP1/dx1 dP1/dx2 ... dP1/dxp P2 dP2/dx1 dP2/dx2 ...dPn/dxp]
        %conditionnement evaluations
        comp=zeros(nb_val,nb_var);
        eva=[ev comp]';
        %conditionnement gradients
        comp=zeros(nb_val,1);
        deva=[comp dev]';
        %creation vecteur evaluations/gradients
        P=eva'+deva';        
    end
else
    if calc_grad  %si calcul des gradients
        [P,dP]=feval(donnees.build.fct,dist,donnees.build.para.val);
    else %sinon
        P=feval(donnees.build.corr,dist,donnees.build.para.val);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Evaluation du m�tamod�le au point X
Z=P'*donnees.build.w;
if calc_grad
   GZ=dP'*donnees.build.w;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation
if donnees.norm.on
    infos.moy=donnees.norm.moy_eval;
    infos.std=donnees.norm.std_eval;
    Z=norm_denorm(Z,'denorm',infos);
    if calc_grad
        infos.std_e=donnees.norm.std_eval;
        infos.std_t=donnees.norm.std_tirages;
        GZ=norm_denorm_g(GZ','denorm',infos); clear infos
        GZ=GZ';
    end
end


end