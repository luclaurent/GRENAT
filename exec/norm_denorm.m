%% fonction assurant la normalisation/denormalisation des donnees
%% L. LAURENT -- 18/10/2011 -- laurent@lmt.ens-cachan.fr

function [out,infos]=norm_denorm(in,infos)


%calcul des moyennes et des ecarts type
    moy_i=mean(in)
    std_i=std(in)

    
    %test pour verification ecart type
    ind=find(std_i==0);
    if ~isempty(ind)
        std_i(ind)=1;
    end
    
    %normalisation
    evaln=(eval-repmat(moy_e,nbs,1))./repmat(std_e,nbs,1);
    tiragesn=(tirages-repmat(moy_t,nbs,1))./repmat(std_t,nbs,1);
    gradn=grad.*repmat(std_t,nbs,1)/std_e;