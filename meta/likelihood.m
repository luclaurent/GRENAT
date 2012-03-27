%%Fonction permettant le calcul de la vraisemblance et de la log
%%vraisemblance
%L. LAURENT -- 10/11/2010 -- laurent@lmt.ens-cachan.fr

%le calcul realise ici s'applique au krigeage
%% //!\\ calcul du logarithme népérien du determinant manuellement pour eviter les prob de précision de matlab
function [logli,li]=likelihood(donnees)

%taille matrice de correlation
tail_rcc=size(donnees.build.rcc,1);


%calcul de la log vraisemblance d'apres Jones 1993 / Leary 2004
switch donnees.build.fact_rcc
    case 'QR'
        detQrcc=det(donnees.build.Qrcc);
        diagRrcc=diag(donnees.build.Rrcc);
        det_corr=abs(prod(diagRrcc)); %Q est une matrice unitaire        
        log_det_corr=sum(log(abs(diagRrcc)));
        %contrôle positivité
        sumd=sum(diagRrcc<0);
        if mod(sumd,2)~=0&&detQrcc>0
           fprintf('<< Matrice de corrélation non positive >>\n'); 
        end
    case 'LL'
        fprintf('Cholesky non optimisé dans likelihood.m')
        eig_val=eig(donnees.build.rcc);
        det_corr=prod(eig_val);        
        log_det_corr=sum(log(eig_val));
                %contrôle positivité
        sumd=sum(eig_val<0);
        if mod(sumd,2)~=0
           fprintf('<< Matrice de corrélation non positive >>\n'); 
        end
    case 'LU'
        diagUrcc=diag(donnees.build.Urcc);
        det_corr=prod(diagUrcc); %L est quasi triangulaire (à une permutation près) et la matrice L comporte des 1 sur la diagonale
        log_det_corr=sum(log(abs(diagUrcc)));
        %contrôle positivité
        sumd=sum(diagUrcc<0);
        if mod(sumd,2)~=0
           fprintf('<< Matrice de corrélation non positive >>\n'); 
        end
    otherwise
        eig_val=eig(donnees.build.rcc);
        det_corr=prod(eig_val);        
        log_det_corr=sum(log(eig_val));
         %contrôle positivité
        sumd=sum(eig_val<0);
        if mod(sumd,2)~=0
           fprintf('<< Matrice de corrélation non positive >>\n'); 
        end
end


%rr=donnees.build.rcc;
%global rr
%log_det_corr
logli=tail_rcc/2*log(2*pi*donnees.build.sig2)+1/2*log_det_corr+tail_rcc/2;
if isinf(logli)||isnan(logli)
    logli=1e16;
end

if nargout==2
    %calcul de la vraisemblance d'apres Jones 1993 / Leary 2004
    li=1/((2*pi*donnees.build.sig2)^(tail_rcc/2)*sqrt(det_corr));

elseif nargout >2
    error('Mauvais nombre de parametres de sortie de la fonction likelihood.m');
end
