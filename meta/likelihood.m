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

logli=-nb_t/2*log(2*pi)-1/2*log(det(mat_corr))-1/2*fobs'/mat_corr*fobs;

if nargout==2
    %calcul de la vraisemblance d'après Jones 1993
    li=1/((2*pi)^(nb_t/2)*sqrt(det(mat_corr)))*exp(-1/2*fobs'/mat_corr*fobs);

elseif nargout >2
    error('Mauvais nombre de parametres de sortie de la fonction likelihood.m');
end
