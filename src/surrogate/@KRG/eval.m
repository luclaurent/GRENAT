%% Method of KRG class
% L. LAURENT -- 07/08/2017 -- luc.laurent@lecnam.net

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


%% Evaluation of the metamodel
% INPUTS:
% - X: point on whiche the evaluation must be computed
% OUTPUTS:
% - Z: approximate response provided by the metamodel
% - GZ: approximate gradient provided by the metamodel
% - variance: variance provided by the metamodel

function [Z,GZ,variance]=eval(obj,X)
%
if obj.requireCompute;obj.train;end
%
%computation of thr gradients or not (depending on the number of output variables)
if nargout>=2
    calcGrad=true;
else
    calcGrad=false;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ns=obj.nS;
np=obj.nP;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KRG/GKRG
%%compute response provided by the metamodel at the non sample point
%definition des dimensions of the matrix/vector for KRG or GKRG
if obj.flagG
    sizeMatVec=ns*(np+1);
else
    sizeMatVec=ns;
end

%kernel (correlation) vector between sample point and the non sample point
rr=zeros(sizeMatVec,1);
if calcGrad
    jr=zeros(sizeMatVec,np);
end
%KRG/GKRG
if obj.flagG
    if calcGrad  %if compute gradients
        %evaluate kernel function
        [ev,dev,ddev]=obj.kernelMatrix.buildVector(X,obj.paraVal);
        rr(1:ns)=ev;
        rr(ns+1:sizeMatVec)=-reshape(dev',1,ns*np);
        
        %derivative of the kernel vector between sample point and the non sample point
        jr(1:ns,:)=dev;
        
        % second derivatives
        matDer=zeros(np,np*ns);
        for mm=1:ns
            matDer(:,(mm-1)*np+1:mm*np)=ddev(:,:,mm);
        end
        jr(ns+1:sizeMatVec,:)=-matDer';
        
        %if missing data
        if obj.checkMiss
            rr=obj.missData.removeGRV(rr);
            jr=obj.missData.removeGRV(jr);
        end
    else %otherwise
        [ev,dev]=obj.kernelMatrix.buildVector(X,obj.paraVal);
        rr(1:ns)=ev;
        rr(ns+1:sizeMatVec)=-reshape(dev',1,ns*np);
        %if missing data
        if obj.checkMiss
            rr=obj.missData.removeGRV(rr);
        end
    end
else
    if calcGrad  %if the gradients will be computed
        [rr,jr]=obj.kernelMatrix.buildVector(X,obj.paraVal);
        %if missing data
        if obj.checkMiss
            rr=obj.missData.removeRV(rr);
            jr=obj.missData.removeRV(jr);
        end
    else %otherwise
        rr=obj.kernelMatrix.buildVector(X,obj.paraVal);
        %if missing data
        if obj.checkMiss
            rr=obj.missData.removeRV(rr);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%regression matrix at the non-sample points
if calcGrad
    [ff,jf]=obj.krgLS.buildMatrixNonS(X);
else
    [ff]=obj.krgLS.buildMatrixNonS(X);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%evaluation of the surrogate model at point X
trZ=ff*obj.beta;
stoZ=rr'*obj.gamma;
Z=trZ+stoZ;
if calcGrad
    %%verif in 2D+
    trGZ=jf*obj.beta;
    stoGZ=jr'*obj.gamma;
    GZ=trGZ+stoGZ;
end
%compute variance
if nargout >=3
    variance=obj.computeVariance(rr,ff);
end
end
