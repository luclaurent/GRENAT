%% Compute error criteria and display
%% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

function [err,errV,errNAME]=critErrDisp(Zap,Zref,data)

fprintf('#########################################\n');
fprintf('   >>> Compute error criteria <<<\n');
[tMesu,tInit]=mesu_time;

%Reordering data
if isa(Zap,'struct');Zap=Zap.Z;end
if isa(Zref,'struct');Zap=Zap.Z;end

TMPerrV=[];
TMPErrNAME=[];

%list of available errors (comparison exact/approximated values) 
errREF={'emse','rmse','r','radj','r2','r2adj','rccc','eraae','ermae','eq1','eq2','eq3'};
errREFname={'MSE','RMSE','R','Radj','R2','R2adj','Rccc','RAAE','RMAE','Q1','Q2','Q3'};
%list of Cross-validation errors
errCV={'bm','eloor','eloog','eloot','scvr_mean','scvr_min','scvr_max','press','errp','adequ'};
errCVname={'Mean Bias','MSE (resp)','MSE (grad)','MSE (mix)','SCVR (Mean)',...
    'SCVR (Min)','SCVR (Max)','PRESS','Custom error','Adequation'};
%Likelihood
vLI={'li','logli'};
nameLI={'Likelihood','Log-Likelihood'};


if ~isempty(Zref)
    err.emse=calcMSE(Zref,Zap);
    err.rmse=calcRMSE(Zref,Zap);
    [err.r,err.radj,err.r2,err.r2adj,err.rccc]=corrFact(Zref,Zap);
    err.eraae=calcRAAE(Zref,Zap);
    err.ermae=calcRMAE(Zref,Zap);
    [err.eq1,err.eq2,err.eq3]=qualError(Zref,Zap);
    txt=dispERR(err,errREF,errREFname);
    [TMPval,TMPname]=concatERR(err,errREF,'ref');
    if ~isempty(txt);fprintf(txt);end
    TMPerrV=[TMPerrV TMPval];
    TMPErrNAME=[TMPErrNAME TMPname];
else
    err=[];
end
if nargin==3
    if isfield(data,'cv')&&~isempty(data.cv)
        fprintf('\n>>>Cross-Validation<<<\n');
        if isfield(data.cv,'final');
            err.cv=data.cv.final;
            txt=dispERR(data.cv.final,errCV,errCVname);
            [TMPval,TMPname]=concatERR(err,errREF,'cv');
            if ~isempty(txt);fprintf(txt);end
            TMPerrV=[TMPerrV TMPval];
            TMPErrNAME=[TMPErrNAME TMPname];
        end
        if isfield(data.cv,'and');
            fprintf('\n>>>REP and GR<<<\n');
            txt=dispERR(data.cv.and,errCV,errCVname);
            err.and=data.cv.and;
            [TMPval,TMPname]=concatERR(err,errREF,'cvA');
            if ~isempty(txt);fprintf(txt);end
            TMPerrV=[TMPerrV TMPval];
            TMPErrNAME=[TMPErrNAME TMPname];
        end
        if isfield(data.cv,'then');
            fprintf('\n>>>REP then GR<<<\n');
            txt=dispERR(data.cv.then,errCV,errCVname);
            err.then=data.cv.then;
            [TMPval,TMPname]=concatERR(err,errREF,'cvT');
            if ~isempty(txt);fprintf(txt);end
            TMPerrV=[TMPerrV TMPval];
            TMPErrNAME=[TMPErrNAME TMPname];
        end
    end
    
    if isfield(data,'li')||isfield(data,'logli')
        fprintf('\n>>>Likelihood<<<\n');
        txt=dispERR(data,vLI,nameLI);
        if isfield(data,'li');err.li=data.li;end
        if isfield(data,'logli');err.logli=data.logli;end
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

%function for displaying existing errors
function txt=dispERR(err,type,errName)
txt=[];
for ite=1:numel(type)
    if isfield(err,type{ite})
        txt=[txt sprintf('%s=%g\n',errName{ite},err.(type{ite}))];
    end
end
end

%founction for concatening errors and their names
function [Vval,Vname]=concatERR(err,type,errName)
Vval=[];Vname=[];
for ite=1:numel(type)
    if isfield(err,type{ite})
        Vval=[Vval err.(type{ite})];
        Vname=[Vname errName type{ite} '  '];
    end
end
end