%%Fonction permettant le calcul de la vraisemblance et de la log
%%vraisemblance
%L. LAURENT -- 10/11/2010 -- laurent@lmt.ens-cachan.fr

%le calcul réalisé ici s'applique au krigeage
function [logli,li]=likelihood(mat_corr,y,regr,beta)

%nombre sites
nb_t=size(mat_corr,1);

%calcul de la log vraisemblance d'après Jones 1993
%y: vecteur des evaluations
%regr: matrice de la tendance aux sites d'évaluation
%beta: matrice des coeficients de la regression lineaire (obtenus par
%moindres carres)
fobs=y-regr*beta;

%ecart type
sig=1/nb_t*fobs'/mat_corr*fobs;
det_corr=det(mat_corr);


logli=nb_t/2*log(2*pi*sig)+1/2*log(det_corr)+nb_t/2;

if nargout==2
    %calcul de la vraisemblance d'après Jones 1993
    li=1/((2*pi*sig)^(nb_t/2)*sqrt(det_corr));

elseif nargout >2
    error('Mauvais nombre de parametres de sortie de la fonction likelihood.m');
end
