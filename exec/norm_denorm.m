%% fonction assurant la normalisation/denormalisation des donnees
%% L. LAURENT -- 18/10/2011 -- laurent@lmt.ens-cachan.fr

function [out,infos]=norm_denorm(in,infos)

% nombre d'echantillons
nbs=size(in,1);

%normalisation
if nargin==1
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
    %denormalisation
elseif nargin==2
    out=repmat(infos.std,nbs,1).*in+repmat(infos.moy,nbs,1);
else
    error('Mauvais nombre de parametres d''entr�e (cf. norm_denorm.m)')
end
