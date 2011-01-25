%%Fonction permettant le calcul de la vraisemblance et de la log
%%vraisemblance
%L. LAURENT -- 10/11/2010 -- laurent@lmt.ens-cachan.fr

%le calcul realise ici s'applique au krigeage
function [logli,li]=likelihood(mat_corr,sig)

%nombre sites
nb_t=size(mat_corr,1);

%calcul de la log vraisemblance d'apres Jones 1993
det_corr=det(mat_corr);


logli=nb_t/2*log(2*pi*sig)+1/2*log(det_corr)+nb_t/2;

if nargout==2
    %calcul de la vraisemblance d'apres Jones 1993
    li=1/((2*pi*sig)^(nb_t/2)*sqrt(det_corr));

elseif nargout >2
    error('Mauvais nombre de parametres de sortie de la fonction likelihood.m');
end
