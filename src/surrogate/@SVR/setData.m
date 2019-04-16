%% Method of SVR class
% L. LAURENT -- 18/08/2017 -- luc.laurent@lecnam.net

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


%% prepare data for building (deal with missing data)
% INPUTS:
% - none
% OUTPUTS:
% - none

function setData(obj)
%load data
ns=obj.nS;
np=obj.nP;
c0l=obj.metaData.c0;
ckl=obj.metaData.ck;
nuSVRl=obj.metaData.nuSVR;
nuGSVRl=obj.metaData.nuGSVR;
%Responses and gradients at sample points
YYT=obj.resp;
%remove missing response(s)
if obj.checkMiss
    YYT=obj.missData.removeRV(YYT);
end
%
der=[];
if obj.flagG
    tmp=obj.grad';
    der=tmp(:);
    %remove missing gradient(s)
    if obj.checkMiss
        der=obj.missData.removeGV(der);
    end
end
obj.YY=YYT;
obj.YYD=der;
%
obj.YYtot=[YYT;der];
obj.CC=[-YYT;YYT;-der;der];
%initialize kernel matrix
obj.kernelMatrix=KernMatrix(obj.kernelFun,obj.sampling,obj.getParaVal);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Bounds of the dual variables (R: responses and G: gradients)
obj.lbR=zeros(ns,1);
cv0=c0l/ns*ones(ns,1);
obj.ubR=cv0;
if obj.checkMiss
    obj.ubR=obj.missData.removeRV(obj.ubR);
    obj.lbR=obj.missData.removeRV(obj.lbR);
end
%
obj.lbG=[];
obj.ubG=[];
if obj.flagG
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Conditioning data for gradient-based approach
    if numel(ckl)==1
        ck=ckl(:,ones(1,np));
    end
    obj.lbG=zeros(np*ns,1);
    ckV=ckl(:,ones(1,np*ns))/ns;
    obj.ubG=ckV(:);
    %
    if obj.checkMiss
        obj.ubG=obj.missData.removeGV(obj.ubG);
        obj.lbG=obj.missData.removeGV(obj.lbG);
    end
end
obj.ub=[obj.ubR;obj.ubR;obj.ubG;obj.ubG];
obj.lb=[obj.lbR;obj.lbR;obj.lbG;obj.lbG];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Build equality constraints
obj.AeqR=ones(1,ns);
if obj.checkMiss
    obj.AeqR=obj.missData.removeRV(obj.AeqR');
    obj.AeqR=obj.AeqR';
end
obj.beq=0;
obj.AeqG=[];
if obj.flagG
    obj.AeqG=zeros(1,ns*np);
    if obj.checkMiss
        obj.AeqG=obj.missData.removeGV(obj.AeqG');
        obj.AeqG=obj.AeqG';
    end
end
obj.Aeq=[obj.AeqR -obj.AeqR obj.AeqG -obj.AeqG];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Build inequality constraints
obj.AineqR=ones(1,ns);
if obj.checkMiss
    obj.AineqR=obj.missData.removeRV(obj.AineqR');
    obj.AineqR=obj.AineqR';
end
obj.bineqR=c0l*nuSVRl;
obj.bineqG=[];
obj.AineqG=[];
if obj.flagG
    obj.bineqG=ck(:)*nuGSVRl;
    obj.AineqG=repmat(eye(np),1,ns);
    %
    if obj.checkMiss
        obj.AineqG=obj.missData.removeGV(obj.AineqG');
        obj.AineqG=obj.AineqG';
    end
end
if ~isempty(obj.AineqG)
    sizA=size(obj.AineqG);
    obj.Aineq=[obj.AineqR obj.AineqR zeros(1,2*sizA(2));
        zeros(sizA(1),2*ns) obj.AineqG obj.AineqG];
else
    obj.Aineq=[obj.AineqR obj.AineqR];
end
obj.bineq=[obj.bineqR;obj.bineqG];
end