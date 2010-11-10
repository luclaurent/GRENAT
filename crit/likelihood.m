%%Fonction permettant le calcul de la vraisemblance et de la log
%%vraisemblance
%L. LAURENT -- 10/11/2010 -- laurent@lmt.ens-cachan.fr

%le calcul réalisé ici s'applique au krigeage
[LOGLI,LI]=likelihood(mat_corr,fobs)

%nombre sites
nb_t=size(mat_corr,1);

%calcul de la log vraisemblance d'après Vasquez 2005

LOGLI=-nb_t/2*log(2*pi)-1/2*log(det(mat_corr))-1/2*fobs'*inv(mat_corr)*fobs;

if nargout==2
    %calcul de la vraisemblance d'après Vasquez 2005
    LI=1/((2*pi)^(nb_t/2)*sqrt(det(mat_corr)))*exp(-1/2*fobs'*inv(mat_corr)*fobs);

elseif nargout >2
    error('Mauvais nombre de parametres de sortie de la fonction likelihood.m');
end
end