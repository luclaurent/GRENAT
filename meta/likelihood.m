%%Fonction permettant le calcul de la vraisemblance et de la log
%%vraisemblance
%L. LAURENT -- 10/11/2010 -- laurent@lmt.ens-cachan.fr

%le calcul realise ici s'applique au krigeage
function [logli,li]=likelihood(donnees)

%taille matrice de correlation
tail_rcc=size(donnees.build.rcc,1);


%calcul de la log vraisemblance d'apres Jones 1993 / Leary 2004
det_corr=det(donnees.build.rcc);


logli=tail_rcc/2*log(2*pi*ret.build.sig)+1/2*log(det_corr)+tail_rcc/2;

if nargout==2
    %calcul de la vraisemblance d'apres Jones 1993 / Leary 2004
    li=1/((2*pi*sig)^(tail_rcc/2)*sqrt(det_corr));

elseif nargout >2
    error('Mauvais nombre de parametres de sortie de la fonction likelihood.m');
end
