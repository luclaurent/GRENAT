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

%% Update data for building (deal with missing data)
% INPUTS:
% - samplingIn: array of sample points
% - respIn: vector of responses
% - gradIn: array of gradients
% OUTPUTS:
% - none

function updateData(obj,samplingIn,respIn,gradIn)
%number of new data
NnS=numel(respIn);
%load data
np=obj.nP;
c0l=obj.metaData.c0;
ckl=obj.metaData.ck;
%Responses and gradients at sample points
YYT=respIn;
%remove missing response(s)
if obj.checkNewMiss
    YYT=obj.missData.removeRV(YYT,'n');
end
%
der=[];
if obj.flagG
    tmp=gradIn';
    der=tmp(:);
    %remove missing gradient(s)
    if obj.checkNewMiss
        der=obj.missData.removeGV(der,'n');
    end
end
obj.YY=[obj.YY;-YYT];
obj.YYD=[obj.YYD;-der];
%
obj.YYtot=[obj.YY;obj.YYD];
obj.CC=[-obj.YY;obj.YY;-obj.YYD;obj.YYD];
%initialize kernel matrix
obj.kernelMatrix.updateMatrix(samplingIn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Bounds of the dual variables (R: responses and G: gradients)
nlbR=zeros(NnS,1);
cv0=c0l/obj.nS*ones(NnS,1);
obj.ubR=obj.ubR*(obj.nS-NnS)/obj.nS;
if obj.checkMiss
    nlbR=obj.missData.removeRV(nlbR,'n');
    cv0=obj.missData.removeRV(cv0,'n');
end
obj.lbR=[obj.lbR;nlbR];
obj.ubR=[obj.ubR;cv0];
%
obj.lbG=[];
obj.ubG=[];
if obj.flagG
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Conditioning data for gradient-based approach
    if numel(ckl)==1
        ckl=ckl(:,ones(1,np));
    end
    nlbG=zeros(np*NnS,1);
    ckV=ckl(:,ones(1,np*NnS))/NnS;
    nubG=ckV(:);
    obj.ubG=obj.ubG*(obj.nS-NnS)/obj.nS;
    %
    if obj.checkMiss
        nubG=obj.missData.removeGV(nubG,'n');
        nlbG=obj.missData.removeGV(nlbG,'n');
    end
    obj.lbG=[obj.lbG;nlbG];
    obj.ubG=[obj.ubG;nubG];
end
obj.ub=[obj.ubR;obj.ubR;obj.ubG;obj.ubG];
obj.lb=[obj.lbR;obj.lbR;obj.lbG;obj.lbG];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Build equality constraints
nAeqR=ones(1,NnS);
if obj.checkMiss
    nAeqR=obj.missData.removeRV(nAeqR','n');
    nAeqR=nAeqR';
end
%
obj.AeqR=[obj.AeqR nAeqR];
if obj.flagG
    nAeqG=zeros(1,NnS*np);
    if obj.checkMiss
        nAeqG=obj.missData.removeGV(nAeqG','n');
        nAeqG=nAeqG';
    end
    obj.AeqG=[obj.AeqG nAeqG];
end
obj.Aeq=[obj.AeqR -obj.AeqR obj.AeqG -obj.AeqG];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Build inequality constraints
nAineqR=ones(1,NnS);
if obj.checkMiss
    nAineqR=obj.missData.removeRV(nAineqR','n');
    nAineqR=nAineqR';
end
%
obj.AineqR=[obj.AineqR nAineqR];
if obj.flagG
    nAineqG=repmat(eye(np),1,NnS);
    %
    if obj.checkMiss
        nAineqG=obj.missData.removeGV(nAineqG','n');
        nAineqG=nAineqG';
    end
    obj.AineqG=[obj.AineqG nAineqG];
end
if ~isempty(obj.AineqG)
    sizA=size(obj.AineqG);
    obj.Aineq=[obj.AineqR obj.AineqR zeros(1,2*sizA(2));
        zeros(sizA(1),2*obj.nS) obj.AineqG obj.AineqG];
else
    obj.Aineq=[obj.AineqR obj.AineqR];
end
end