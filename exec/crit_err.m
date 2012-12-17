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
if nargin==3
    if isfield(donnees,'cv')&&~isempty(donnees.cv)
        fprintf('\n>>>Validation croisee<<<\n');
        if isfield(donnees.cv,'bm');fprintf('Biais moyen=%g\n',donnees.cv.bm);err.cv.bm=donnees.cv.bm;end
        if isfield(donnees.cv,'eloor');fprintf('MSE (eval)=%g\n',donnees.cv.eloor);err.cv.eloor=donnees.cv.eloor;end
        if isfield(donnees.cv,'eloog');fprintf('MSE (grad)=%g\n',donnees.cv.eloog);err.cv.eloog=donnees.cv.eloog;end
        if isfield(donnees.cv,'eloot');fprintf('MSE (mix)=%g\n',donnees.cv.eloot);err.cv.eloot=donnees.cv.eloot;end
        if isfield(donnees.cv,'press');fprintf('PRESS=%g\n',donnees.cv.press);err.cv.press=donnees.cv.press;end
        if isfield(donnees.cv,'errp');fprintf('Erreur perso=%g\n',donnees.cv.errp);err.cv.errp=donnees.cv.errp;end
        if isfield(donnees.cv,'adequ');fprintf('Adequation=%g\n',donnees.cv.adequ);err.cv.adequ=donnees.cv.adequ;end
        if isfield(donnees.cv,'and');
            fprintf('\n>>>REP ET GR<<<\n');
            if isfield(donnees.cv.and,'bm');fprintf('Biais moyen=%g\n',donnees.cv.and.bm);err.cv.and.bm=donnees.cv.and.bm;err.cv.bm=donnees.cv.and.bm;end
            if isfield(donnees.cv.and,'eloor');fprintf('MSE (eval)=%g\n',donnees.cv.and.eloor);err.cv.and.eloor=donnees.cv.and.eloor;end
            if isfield(donnees.cv.and,'eloog');fprintf('MSE (grad)=%g\n',donnees.cv.and.eloog);err.cv.theandn.eloog=donnees.cv.and.eloog;end
            if isfield(donnees.cv.and,'eloot');fprintf('MSE (mix)=%g\n',donnees.cv.and.eloot);err.cv.and.eloot=donnees.cv.and.eloot;end
            if isfield(donnees.cv.and,'scvr_mean');fprintf('SCVR (Mean)=%g\n',donnees.cv.and.scvr_mean);err.cv.and.scvr_mean=donnees.cv.and.scvr_mean;err.cv.scvr_mean=donnees.cv.and.scvr_mean;end
            if isfield(donnees.cv.and,'scvr_min');fprintf('SCVR (Min)=%g\n',donnees.cv.and.scvr_min);err.cv.and.scvr_min=donnees.cv.and.scvr_min;err.cv.scvr_min=donnees.cv.and.scvr_min;end
            if isfield(donnees.cv.and,'scvr_max');fprintf('SCVR (Max)=%g\n',donnees.cv.and.scvr_max);err.cv.and.scvr_max=donnees.cv.and.scvr_max;err.cv.scvr_max=donnees.cv.and.scvr_max;end
            if isfield(donnees.cv.and,'press');fprintf('PRESS=%g\n',donnees.cv.and.press);err.cv.and.press=donnees.cv.and.press;end
            if isfield(donnees.cv.and,'errp');fprintf('Erreur perso=%g\n',donnees.cv.and.errp);err.cv.and.errp=donnees.cv.and.errp;end
            if isfield(donnees.cv.and,'adequ');fprintf('Adequation=%g\n',donnees.cv.and.adequ);err.cv.and.adequ=donnees.cv.and.adequ;end
        end
        if isfield(donnees.cv,'then');
            fprintf('\n>>>REP PUIS GR<<<\n');
            if isfield(donnees.cv.then,'bm');fprintf('Biais moyen=%g\n',donnees.cv.then.bm);err.cv.then.bm=donnees.cv.then.bm;err.cv.bm=donnees.cv.then.bm;end
            if isfield(donnees.cv.then,'eloor');fprintf('MSE (eval)=%g\n',donnees.cv.then.eloor);err.cv.then.eloor=donnees.cv.then.eloor;end
            if isfield(donnees.cv.then,'eloog');fprintf('MSE (grad)=%g\n',donnees.cv.then.eloog);err.cv.then.eloog=donnees.cv.then.eloog;end
            if isfield(donnees.cv.then,'eloot');fprintf('MSE (mix)=%g\n',donnees.cv.then.eloot);err.cv.then.eloot=donnees.cv.then.eloot;end
            if isfield(donnees.cv.then,'scvr_mean');fprintf('SCVR (Mean)=%g\n',donnees.cv.then.scvr_mean);err.cv.then.scvr_mean=donnees.cv.then.scvr_mean;err.cv.scvr_mean=donnees.cv.then.scvr_mean;end
            if isfield(donnees.cv.then,'scvr_min');fprintf('SCVR (Min)=%g\n',donnees.cv.then.scvr_min);err.cv.then.scvr_min=donnees.cv.then.scvr_min;err.cv.scvr_min=donnees.cv.then.scvr_min;end
            if isfield(donnees.cv.then,'scvr_max');fprintf('SCVR (Max)=%g\n',donnees.cv.then.scvr_max);err.cv.then.scvr_max=donnees.cv.then.scvr_max;err.cv.scvr_max=donnees.cv.then.scvr_max;end
            if isfield(donnees.cv.then,'press');fprintf('PRESS=%g\n',donnees.cv.then.press);err.cv.then.press=donnees.cv.then.press;end
            if isfield(donnees.cv.then,'errp');fprintf('Erreur perso=%g\n',donnees.cv.then.errp);err.cv.then.errp=donnees.cv.then.errp;end
            if isfield(donnees.cv.then,'adequ');fprintf('Adequation=%g\n',donnees.cv.then.adequ);err.cv.then.adequ=donnees.cv.then.adequ;end
        end
    end
    
    if isfield(donnees,'li')&&isfield(donnees,'logli')
        fprintf('\n>>>Vraisemblance<<<\n');
        fprintf('Likelihood= %6.4d, Log-Likelihood= %6.4d \n\n',donnees.li,donnees.logli);
        err.li=donnees.li;
        err.logli=donnees.logli;
    end
end
mesu_time(tMesu,tInit);
fprintf('#########################################\n');