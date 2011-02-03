%% Calcul des criteres d'erreur et affichage
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function err=crit_err(Zap,Zref,krg)

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
    fprintf('Q1= %6.4d,  Q2= %6.4d,  Q3= %6.4d\n\n',err.eq1,err.eq2,err.eq3);
else
    err=[];
end

if isfield(krg,'cv')
    fprintf('\n>>>Validation croisee<<<\n');
    fprintf('Biais moyen=%g\n',krg.cv.bm);
    fprintf('MSE=%g\n',krg.cv.msep);
    fprintf('Critere adequation=%g\n',krg.cv.adequ)
    fprintf('PRESS=%g\n',krg.cv.press);
end

if isfield(krg,'li')&isfield(krg,'logli')
    fprintf('\n>>>Vraisemblance<<<\n');
    fprintf('Likelihood= %6.4d, Log-Likelihood= %6.4d \n\n',krg.li,krg.logli);
end