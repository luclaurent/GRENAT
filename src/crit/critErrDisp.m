%% Compute error criteria and display
% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox 
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017  Luc LAURENT <luc.laurent@lecnam.net>
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

function [err,errV,errNAME]=critErrDisp(Zap,Zref,data)

Gfprintf('#########################################\n');
Gfprintf('   >>> Compute error criteria <<<\n');
countTime=mesuTime;

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
    if ~isempty(txt);Gfprintf(txt);end
    TMPerrV=[TMPerrV TMPval];
    TMPErrNAME=[TMPErrNAME TMPname];
else
    err=[];
end
if nargin==3
    if isfield(data,'cv')&&~isempty(data.cv)
        Gfprintf('\n>>>Cross-Validation<<<\n');
        if isfield(data.cv,'final');
            err.cv=data.cv.final;
            txt=dispERR(data.cv.final,errCV,errCVname);
            [TMPval,TMPname]=concatERR(err,errREF,'cv');
            if ~isempty(txt);Gfprintf(txt);end
            TMPerrV=[TMPerrV TMPval];
            TMPErrNAME=[TMPErrNAME TMPname];
        end
        if isfield(data.cv,'and');
            Gfprintf('\n>>>REP and GR<<<\n');
            txt=dispERR(data.cv.and,errCV,errCVname);
            err.and=data.cv.and;
            [TMPval,TMPname]=concatERR(err,errREF,'cvA');
            if ~isempty(txt);Gfprintf(txt);end
            TMPerrV=[TMPerrV TMPval];
            TMPErrNAME=[TMPErrNAME TMPname];
        end
        if isfield(data.cv,'then');
            Gfprintf('\n>>>REP then GR<<<\n');
            txt=dispERR(data.cv.then,errCV,errCVname);
            err.then=data.cv.then;
            [TMPval,TMPname]=concatERR(err,errREF,'cvT');
            if ~isempty(txt);Gfprintf(txt);end
            TMPerrV=[TMPerrV TMPval];
            TMPErrNAME=[TMPErrNAME TMPname];
        end
    end
    
    if isfield(data,'li')||isfield(data,'logli')
        Gfprintf('\n>>>Likelihood<<<\n');
        txt=dispERR(data,vLI,nameLI);
        if isfield(data,'li');err.li=data.li;end
        if isfield(data,'logli');err.logli=data.logli;end
        [TMPval,TMPname]=concatERR(donnee,vLI,'');
        if ~isempty(txt);Gfprintf(txt);end
        TMPerrV=[TMPerrV TMPval];
        TMPErrNAME=[TMPErrNAME TMPname];
    end
    if nargin>1
        errV=TMPerrV;
        errNAME=TMPErrNAME;
    end
end
countTime.stop;
Gfprintf('#########################################\n');
end

%function for displaying existing errors
function txt=dispERR(err,type,errName)
%sizes of all names of errors
sName=cellfun(@numel,errName);
maxsN=max(sName);

txt=[];
for ite=1:numel(type)
    if isfield(err,type{ite})
        %add spaces (calculate number of spaces
        nbSpaces=maxsN-sName(ite)+2;
        charSpace=' ';
        txt=[txt sprintf('%s:%s%g\n',errName{ite},charSpace(ones(1,nbSpaces)),err.(type{ite}))];
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
