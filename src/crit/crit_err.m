%% Calcul des criteres d'erreur et affichage
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function [err,errV,errNAME]=crit_err(Zap,Zref,donnees)

fprintf('#########################################\n');
fprintf('   >>> CALCUL CRITERES ERREUR <<<\n');
[tMesu,tInit]=mesu_time;

%Ajustement des variables
if isa(Zap,'struct');Zap=Zap.Z;end
if isa(Zref,'struct');Zap=Zap.Z;end

TMPerrV=[];
TMPErrNAME=[];

%liste erreur par rapport reference
errREF={'emse','rmse','r','radj','r2','r2adj','eraae','ermae','eq1','eq2','eq3'};
errREFname={'MSE','RMSE','R','Radj','R2','R2adj','RAAE','RMAE','Q1','Q2','Q3'};
%liste erreur CV
errCV={'bm','eloor','eloog','eloot','scvr_mean','scvr_min','scvr_max','press','errp','adequ'};
errCVname={'Biais moyen','MSE (eval)','MSE (grad)','MSE (mix)','SCVR (Mean)',...
    'SCVR (Min)','SCVR (Max)','PRESS','Erreur perso','Adequation'};
%vraisemblance
vLI={'li','logli'};
nameLI={'Likelihood','Log-Likelihood'};


if ~isempty(Zref)
    err.emse=mse_p(Zref,Zap);
    err.rmse=rmse_p(Zref,Zap);
    [err.r,err.radj,err.r2,err.r2adj]=fact_corr(Zref,Zap);
    err.eraae=raae(Zref,Zap);
    err.ermae=rmae(Zref,Zap);
    [err.eq1,err.eq2,err.eq3]=qual(Zref,Zap);
    txt=dispERR(err,errREF,errREFname);
    [TMPval,TMPname]=concatERR(err,errREF,'ref');
    if ~isempty(txt);fprintf(txt);end
    TMPerrV=[TMPerrV TMPval];
    TMPErrNAME=[TMPErrNAME TMPname];
else
    err=[];
end
if nargin==3
    if isfield(donnees,'cv')&&~isempty(donnees.cv)
        fprintf('\n>>>Validation croisee<<<\n');
        if isfield(donnees.cv,'final');
            err.cv=donnees.cv.final;
            txt=dispERR(donnees.cv.final,errCV,errCVname);
            [TMPval,TMPname]=concatERR(err,errREF,'cv');
            if ~isempty(txt);fprintf(txt);end
            TMPerrV=[TMPerrV TMPval];
            TMPErrNAME=[TMPErrNAME TMPname];
        end
        if isfield(donnees.cv,'and');
            fprintf('\n>>>REP ET GR<<<\n');
            txt=dispERR(donnees.cv.and,errCV,errCVname);
            err.and=donnees.cv.and;
            [TMPval,TMPname]=concatERR(err,errREF,'cvA');
            if ~isempty(txt);fprintf(txt);end
            TMPerrV=[TMPerrV TMPval];
            TMPErrNAME=[TMPErrNAME TMPname];
        end
        if isfield(donnees.cv,'then');
            fprintf('\n>>>REP PUIS GR<<<\n');
            txt=dispERR(donnees.cv.then,errCV,errCVname);
            err.then=donnees.cv.then;
            [TMPval,TMPname]=concatERR(err,errREF,'cvT');
            if ~isempty(txt);fprintf(txt);end
            TMPerrV=[TMPerrV TMPval];
            TMPErrNAME=[TMPErrNAME TMPname];
        end
    end
    
    if isfield(donnees,'li')||isfield(donnees,'logli')
        fprintf('\n>>>Vraisemblance<<<\n');
        txt=dispERR(donnees,vLI,nameLI);
        if isfield(donnees,'li');err.li=donnees.li;end
        if isfield(donnees,'logli');err.logli=donnees.logli;end
        [TMPval,TMPname]=concatERR(donnee,vLI,'');
        if ~isempty(txt);fprintf(txt);end
        TMPerrV=[TMPerrV TMPval];
        TMPErrNAME=[TMPErrNAME TMPname];
    end
    if nargin>1
        errV=TMPerrV;
        errNAME=TMPErrNAME;
    end
end
mesu_time(tMesu,tInit);
fprintf('#########################################\n');
end

%fonction d'affichage des erreurs existantes
function txt=dispERR(err,type,nom)
txt=[];
for ite=1:numel(type)
    if isfield(err,type{ite})
        txt=[txt sprintf('%s=%g\n',nom{ite},err.(type{ite}))];
    end
end
end

%fonction de concatenation des erreurs et de leur nom
function [Vval,Vnom]=concatERR(err,type,nom)
Vval=[];Vnom=[];
for ite=1:numel(type)
    if isfield(err,type{ite})
        Vval=[Vval err.(type{ite})];
        Vnom=[Vnom nom type{ite} '  '];
    end
end
end