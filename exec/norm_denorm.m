%% fonction assurant la normalisation/denormalisation des donnees
%% L. LAURENT -- 18/10/2011 -- laurent@lmt.ens-cachan.fr

function [out,infos]=norm_denorm(in,type,infos)

% nombre d'echantillons
nbs=size(in,1);
if (nargin==3&&~isempty(infos.moy))||nargin==2
    %normalisation
    if strcmp(type,'norm')
        if nargin==3
            out=(in-repmat(infos.moy,nbs,1))./repmat(infos.std,nbs,1);
        else
            %calcul des moyennes et des ecarts type
            moy_i=mean(in);
            std_i=std(in);
            %test pour verification ecart type
            ind=find(std_i==0);
            if ~isempty(ind)
                std_i(ind)=1;
            end
            
            out=(in-repmat(moy_i,nbs,1))./repmat(std_i,nbs,1);
            if nargout==2
                infos.moy=moy_i;
                infos.std=std_i;
            end
        end
        %denormalisation
    elseif strcmp(type,'denorm')
        out=repmat(infos.std,nbs,1).*in+repmat(infos.moy,nbs,1);
        %denormalisation d'une difference de valeurs normalisees
    elseif strcmp(type,'denorm_diff')
        out=repmat(infos.std,nbs,1).*in;
    else
        error('Mauvais nombre de parametres d''entrée (cf. norm_denorm.m)')
    end
else
    out=in;
end
