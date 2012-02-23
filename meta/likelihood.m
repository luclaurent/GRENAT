%%Fonction permettant le calcul de la vraisemblance et de la log
%%vraisemblance
%L. LAURENT -- 10/11/2010 -- laurent@lmt.ens-cachan.fr

%le calcul realise ici s'applique au krigeage
function [logli,li]=likelihood(donnees)

%taille matrice de correlation
tail_rcc=size(donnees.build.rcc,1);


%calcul de la log vraisemblance d'apres Jones 1993 / Leary 2004
switch donnees.build.fact_rcc
    case 'QR'
        det_corr=abs(prod(diag(donnees.build.Rrcc))); %Q est une matrice unitaire
    case 'LL'
        fprintf('Cholesky non codé dans likelihood.m')
    case 'LU'
        det_corr=det(donnees.build.Lrcc)*prod(diag(donnees.build.Urcc)); %L est quasi triangulaire (à une permutation près)
    otherwise
        det_corr=det(donnees.build.rcc);
end


logli=tail_rcc/2*log(2*pi*donnees.build.sig2)+1/2*log(det_corr)+tail_rcc/2;

if nargout==2
    %calcul de la vraisemblance d'apres Jones 1993 / Leary 2004
    li=1/((2*pi*donnees.build.sig2)^(tail_rcc/2)*sqrt(det_corr));

elseif nargout >2
    error('Mauvais nombre de parametres de sortie de la fonction likelihood.m');
end
