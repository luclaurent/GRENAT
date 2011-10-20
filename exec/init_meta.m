%% Initialisation du metamodele
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function meta=init_meta(type,deg,long,corr)

meta.type=type;         %type de metamodele KRG/CKRG/DACE/RBF
meta.deg=deg;           %degre de la regression
meta.para.val=long;       %longueur de correlation
if nargin>=4
    meta.corr=['corr_' corr];     %fonction de correlation
else
    meta.corr='corr_gauss';
end
fctp='reg_poly';
meta.regr=[fctp num2str(deg,'%d')];      %fonction de regression


if strcmp(type,'DACE')
    fctp='regpoly';
    meta.regr=[fctp num2str(deg,'%d')];      %fonction de regression
    meta.corr=['corr' corr];    %fonction de correlation
end

%normalisation
meta.norm=true;         %normalisation
meta.recond=false;      %amelioration du conditionnement de la matrice de correlation
meta.cv=true;           %validation croisee

%estimation parametre long (longueur de correlation)
meta.para.method='fmincon';     % méthode de minimisation de la log-vraisemblance
meta.para.estim=true;           % recherche de la longueur de corrélation
meta.para.aff_likelihood=true;  %affichage de la vraisemblance 1 ou 2 paramètres
meta.para.aniso=false;   %prise en compte de l'anisotropie (longueur de corrélation suivant chaque dimension)
if meta.para.estim
    meta.para.max=long(2);
    meta.para.min=long(1);
end

%Verification interpolation 
meta.verif=true;

