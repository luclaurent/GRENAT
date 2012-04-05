%% fonction assurant la normalisation/denormalisation des donnees de type gradients
%% L. LAURENT -- 19/10/2011 -- laurent@lmt.ens-cachan.fr

function [out]=norm_denorm_g(in,type,infos)

% nombre d'echantillons
nbs=size(in,1);
% normalisation des donnees
if strcmp(type,'norm')
    out=in.*repmat(infos.std_t,nbs,1)/infos.std_e;    
elseif strcmp(type,'denorm')
    out=in*infos.std_e./repmat(infos.std_t,nbs,1);    
else
    error('Mauvais type de normalisation/denormalisation (cf. norm_denorm_g.m)')
    
end

