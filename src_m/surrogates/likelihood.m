%%Fonction permettant le calcul de la vraisemblance et de la log
%%vraisemblance
%L. LAURENT -- 10/11/2010 -- luc.laurent@lecnam.net

%le calcul realise ici s'applique au krigeage
%% //!\\ calcul du logarithme neperien du determinant manuellement pour eviter les prob de precision de matlab
function [logli,li]=likelihood(donnees)

%taille matrice de correlation
tail_rcc=size(donnees.build.rcc,1);

%calcul de la log vraisemblance d'apres Jones 1993 / Leary 2004
switch donnees.build.fact_rcc
    case 'QR'
        diagRrcc=diag(donnees.build.Rrcc);
        det_corr=abs(prod(diagRrcc)); %Q est une matrice unitaire
        log_det_corr=sum(log(abs(diagRrcc)));
    case 'LL'
        diagLrcc=diag(donnees.build.Lrcc);
        det_corr=prod(diagLrcc)^2;
        log_det_corr=2*sum(log(abs(diagLrcc)));
    case 'LU'
        diagUrcc=diag(donnees.build.Urcc);
        det_corr=prod(diagUrcc); %L est quasi triangulaire (a une permutation pres) et la matrice L comporte des 1 sur la diagonale
        log_det_corr=sum(log(abs(diagUrcc)));
    otherwise
        eig_val=eig(donnees.build.rcc);
        det_corr=prod(eig_val);
        log_det_corr=sum(log(eig_val));
end
global lisack
logli=tail_rcc/2*log(2*pi*donnees.build.sig2)+1/2*log_det_corr+tail_rcc/2;
lisack=abs(det_corr)^(1/tail_rcc)*donnees.build.sig2;
%logli=lisack;

if isinf(logli)||isnan(logli)
    logli=1e16;
end

if nargout==2
    %calcul de la vraisemblance d'apres Jones 1993 / Leary 2004
    li=1/((2*pi*donnees.build.sig2)^(tail_rcc/2)*sqrt(det_corr))*exp(-tail_rcc/2);
    
elseif nargout >2
    error('Mauvais nombre de parametres de sortie de la fonction likelihood.m');
end

