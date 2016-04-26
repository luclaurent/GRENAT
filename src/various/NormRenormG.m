%% fonction assurant la normalisation/denormalisation des donnees de type gradients
%% L. LAURENT -- 19/10/2011 -- luc.laurent@lecnam.net

function [out]=norm_denorm_g(in,type,infos)

% nombre d'echantillons
nbs=size(in,1);
% normalisation des donnees
if (nargin==3&&~isempty(infos.std_t))||nargin==2
    switch type
        case 'norm'
            std_t=infos.std_t;
            std_e=infos.std_e;
            out=in.*std_t(ones(nbs,1),:)./std_e;
        case 'denorm'
            std_t=infos.std_t;
            out=in*infos.std_e./std_t(ones(nbs,1),:);
        case 'denorm_concat'  %gradients concatenes en un vecteur colonne
            correct=infos.std_e./infos.std_t;
            nbv=numel(infos.std_t);
            out=in.*repmat(correct(:),nbs/nbv,1);
        otherwise
            error('Mauvais type de normalisation/denormalisation (cf. norm_denorm_g.m)')
            
    end
else
    out=in;
end

