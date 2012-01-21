%% Calcul des criteres d'erreur et affichage
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function err=crit_err(Zap,Zref,donnees)

if ~isempty(Zref)
    err.emse=mse_p(Zref,Zap);
    err.r2=r_square(Zref,Zap);
    err.eraae=raae(Zref,Zap);
    err.ermae=rmae(Zref,Zap);
    [err.eq1,err.eq2,err.eq3]=qual(Zref,Zap);
    fprintf('\nMSE= %6.4d\n',err.emse);
    fprintf('R2= %6.4d\n',err.r2);
    fprintf('RAAE= %6.4d\n',err.eraae);
    fprintf('RMAE= %6.4d\n',err.ermae);
    fprintf('Q1= %6.4d\nQ2= %6.4d\nQ3= %6.4d\n\n',err.eq1,err.eq2,err.eq3);
else
    err=[];
end

if isfield(donnees,'cv')
    fprintf('\n>>>Validation croisee<<<\n');
    fprintf('Biais moyen=%g\n',donnees.cv.bm);
    fprintf('MSE=%g\n',donnees.cv.msep);
    %fprintf('Critere adequation=%g\n',donnees.cv.adequ)
    fprintf('PRESS=%g\n',donnees.cv.press);
    err.cv.bm=donnees.cv.bm;
    err.cv.msep=donnees.cv.msep;
    %err.cv.adequ=donnees.cv.adequ;
    err.cv.press=donnees.cv.press;
end

if isfield(donnees,'li')&&isfield(donnees,'logli')
    fprintf('\n>>>Vraisemblance<<<\n');
    fprintf('Likelihood= %6.4d, Log-Likelihood= %6.4d \n\n',donnees.li,donnees.logli);
    err.li=donnees.li;
    err.logli=donnees.logli;
end