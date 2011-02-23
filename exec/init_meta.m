%% Initialisation du metamodele
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function meta=init_meta(type,deg,long,corr)

meta.type=type;         %type de metamodele KRG/CKRG/DACE
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
meta.para.method='fmincon';
meta.para.estim=true;
meta.para.aff_likelihood=true;
if meta.para.estim
    meta.para.max=long(2);
    meta.para.min=long(1);
end
