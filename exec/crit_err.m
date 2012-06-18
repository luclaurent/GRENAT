%% Calcul des criteres d'erreur et affichage
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function err=crit_err(Zap,Zref,donnees)

fprintf('#########################################\n');
fprintf('   >>> CALCUL CRITERES ERREUR <<<\n');
[tMesu,tInit]=mesu_time;

if ~isempty(Zref)
    err.emse=mse_p(Zref,Zap);
    err.rmse=rmse_p(Zref,Zap);
    [err.r,err.radj,err.r2,err.r2adj]=fact_corr(Zref,Zap);
    err.eraae=raae(Zref,Zap);
    err.ermae=rmae(Zref,Zap);
    [err.eq1,err.eq2,err.eq3]=qual(Zref,Zap);
    fprintf('\nMSE= %6.4d\n',err.emse);
    fprintf('RMSE= %6.4d\n',err.rmse);
    fprintf('R= %6.4d\n',err.r);
    fprintf('R_adj= %6.4d\n',err.radj);
    fprintf('R2= %6.4d\n',err.r2);
    fprintf('R2_adj= %6.4d\n',err.r2adj);
    fprintf('RAAE= %6.4d\n',err.eraae);
    fprintf('RMAE= %6.4d\n',err.ermae);
    fprintf('Q1= %6.4d\nQ2= %6.4d\nQ3= %6.4d\n\n',err.eq1,err.eq2,err.eq3);
else
    err=[];
end

if isfield(donnees,'cv')&&~isempty(donnees.cv)
    fprintf('\n>>>Validation croisee<<<\n');
    if isfield(donnees.cv.perso,'bm');fprintf('Biais moyen=%g\n',donnees.cv.perso.bm);err.cv.bm=donnees.cv.perso.bm;end
    if isfield(donnees.cv,'eloor');fprintf('MSE (eval)=%g\n',donnees.cv.eloor);err.cv.msep=donnees.cv.eloor;end
    if isfield(donnees.cv,'eloog');fprintf('MSE (grad)=%g\n',donnees.cv.eloog);err.cv.mseg=donnees.cv.eloog;end
    if isfield(donnees.cv,'eloot');fprintf('MSE (mix)=%g\n',donnees.cv.eloot);err.cv.msemix=donnees.cv.eloot;end
    if isfield(donnees.cv,'scvr_mean');fprintf('SCVR (Mean)=%g\n',donnees.cv.scvr_mean);err.cv.scvr_mean=donnees.cv.scvr_mean;end
    if isfield(donnees.cv,'scvr_min');fprintf('SCVR (Min)=%g\n',donnees.cv.scvr_min);err.cv.scvr_min=donnees.cv.scvr_min;end
    if isfield(donnees.cv,'scvr_max');fprintf('SCVR (Max)=%g\n',donnees.cv.scvr_max);err.cv.scvr_max=donnees.cv.scvr_max;end
    if isfield(donnees.cv.perso,'press');fprintf('PRESS=%g\n',donnees.cv.perso.press);err.cv.press=donnees.cv.perso.press;end
    if isfield(donnees.cv.perso,'errp');fprintf('Erreur perso=%g\n',donnees.cv.perso.errp);err.cv.errp=donnees.cv.perso.errp;end
end

if isfield(donnees,'li')&&isfield(donnees,'logli')
    fprintf('\n>>>Vraisemblance<<<\n');
    fprintf('Likelihood= %6.4d, Log-Likelihood= %6.4d \n\n',donnees.li,donnees.logli);
    err.li=donnees.li;
    err.logli=donnees.logli;
end

mesu_time(tMesu,tInit);
fprintf('#########################################\n');