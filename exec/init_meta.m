%% Initialisation du métamodèle
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function meta=init_meta(type,deg,theta,corr)

meta.type=type;         %type de métamodèle KRG/CKRG/DACE
meta.deg=deg;           %degre de la regression
meta.theta=theta;       %longueur de corrélation
if nargin>=4
    meta.corr=['corr_' corr];     %fonction de correlation
else
    meta.corr='corr_gauss';
end
fctp='reg_poly';
meta.regr=[fctp num2str(deg,'%d')];      %fonction de régression


if strcmp(type,'DACE')
    fctp='regpoly';
    meta.regr=[fctp num2str(deg,'%d')];      %fonction de régression
    meta.corr=['corr' corr];    %fonction de correlation
end

%normalisation
meta.norm=true;         %normalisation
meta.recond=false;      %amelioration du conditionnement de la matrice de correlation
meta.cv=true;           %validation croisée