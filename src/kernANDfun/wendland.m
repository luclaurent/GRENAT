%% Function: Generalized Wendland's kernel function
%% L. LAURENT -- 05/04/2018 -- luc.laurent@lecnam.net

% ref: H. Wendland. Piecewise polynomial, positive definite and compactly supported radial functions of minimal degree. Advances in Computational Mathematics, 4(1):389?396, 1995.

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

function [k,dk,ddk]=wendland(xx,para,valW)

%number of output parameters
nbOut=nargout;

%number of design variables
nP=size(xx,2);
if nP~=1
    error(['Wrong number of hyperparameters (',mfilename,')']);
end

%extract length hyperparameters
lP=1./para(:,1);

%extract Wendland's parameters (integers)
nu=valW(1);
mu=valW(2); %k in the paper

%evaluation of the function
tc=xx./lP;
td=abs(tc);

%piecewise function
b1=1;
IX1=(td<b1);

%exponents
exR=0:mu;
exPhi=nu+mu-exR;

%compute beta's coefficients
beta=computeBeta(nu,mu,mu);

%compute function
ev1=1-td;
%
kev1=ev1.^exPhi;
%
ev2=td.^exR;
%
evt=beta(mu+1,1:mu+1).*kev1.*ev2;
%
k=sum(evt,2).*IX1;

%compute first derivatives
if nbOut>1
    %
    sxx=sign(xx);
    %
    dexPhi=exPhi-1;
    dexR=exR-1;
    dexR(1)=0; %correction for first derivative
    %
    dkev1=-exPhi.*ev1.^dexPhi;
    dev2=exR.*td.^dexR;
    %
    devt=beta(mu+1,1:mu+1).*(dkev1.*ev2+kev1.*dev2);
    %
    dk=sxx./lP.*sum(devt,2).*IX1;
end

%compute second derivatives
if nbOut>2
    %
    ddexR=dexR-1;
    ddexR(1)=0; %correction for first derivative
    if mu>1;ddexR(2)=0;end %correction for second derivative
    %
    ddkev1=exPhi.*dexPhi.*ev1.^(dexPhi-1);    
    ddev2=exR.*dexR.*td.^ddexR;
    %
    ddevt=beta(mu+1,1:mu+1).*(ddev2.*kev1+2*dkev1.*dev2+ev2.*ddkev1);
    %
    ddk=1./lP.^2.*sum(ddevt,2).*IX1;
end
end

%% specific functions
function out=funA(inX,eX)
% array of terms
vT=inX:-1:inX-eX+1;
%output
out=prod(vT);
end
%
function out=funB(inX,eX)
% array of terms
vT=inX:inX+eX-1;
%output
out=prod(vT);
end
%
function out=computeBeta(nu,inX,inY)
%initialize beta values
out=zeros(inX+2,inY+2);
out(1,1)=1;
%compute coefficients
%partU=bsxfun(@funA,inX-1:inY-1,0:inY-InX);
%partL=bsxfun(@funB,nu+2*(inY-1:-1:nu+inY-2),1:inY-inX+2);
for itJ=1:inX+1
    for itK=1:inY+1
        for itN=itJ-1:itK
            if itN~=0
                out(itJ,itK+1)=...
                    out(itJ,itK+1)+...
                    out(itN,itK)*funA(itN+1,itN-itJ)/funB(nu+2*itK-itN+1,itN-itJ+1);
            end
        end
    end
end
out=out';
end