%% Initialisation du metamodele
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function meta=init_meta(in)

meta.grad=in.grad; %prise en compte des gradients

meta.type=in.type;         %type de metamodele KRG/CKRG/DACE/RBF
meta.deg=in.para.deg;           %degre de la regression
meta.para.val=in.para.long(1);       %longueur de correlation
if nargin>=4
    meta.corr=['corr_' in.corr];     %fonction de correlation
else
    meta.corr='corr_gauss';
end
fctp='reg_poly';
meta.regr=[fctp num2str(in.para.deg,'%d')];      %fonction de regression

%en focntion du type de métamodele
switch in.type
    case 'SWF'
        meta.swf_para=in.para.swf_para;
    case 'DACE'
        if strcmp(type,'DACE')
            fctp='regpoly';
            meta.regr=[fctp num2str(in.para.deg,'%d')];      %fonction de regression
            meta.corr=['corr' in.corr];    %fonction de correlation
        end
    case {'RBF','HBRBF'}
        meta.fct=['rf_' in.rbf];
        meta.para.val=in.para.rbf_para;
end

%normalisation
meta.norm=true;         %normalisation
meta.recond=false;      %amelioration du conditionnement de la matrice de correlation
meta.cv=true;           %validation croisee
meta.cv_aff=true;       %affichage QQ plot CV

%estimation parametre long (longueur de correlation)
meta.para.method='fmincon';     % méthode de minimisation de la log-vraisemblance
meta.para.estim=true;           % recherche de la longueur de corrélation
meta.para.aff_estim=false;  %affichage de la fonctionnelle à miniser pour obtenir le "meilleur" jeu de parametres
meta.para.aniso=true;   %prise en compte de l'anisotropie (longueur de corrélation suivant chaque dimension)
meta.para.aff_iter_graph=false; %affichage iteration estimation paramètres sur un graph (1D/2D)
meta.para.aff_iter_cmd=false;   %affichage iteration dans la console
if meta.para.estim
    meta.para.max=in.para.long(2);
    meta.para.min=in.para.long(1);
end



%Verification interpolation
meta.verif=true;

