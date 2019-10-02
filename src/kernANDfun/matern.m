%% Matern kernel function
% L. LAURENT -- 06/02/2013 (r: 31/08/2015)-- luc.laurent@lecnam.net
%
%nd+1 hyperparameters (length + nd smoothness parameters)

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

function [k,dk,ddk]=matern(xx,para)
%number of output parameters
nbOut=nargout;
%check hyperparameters
nP=size(para,2);
if nP~=2
    error(['Wrong number of hyperparameters (',mfilename,')']);
end

%extract length and smoothness hyperparameters
lP=1./para(:,1);
lS=para(:,2);

%useful functions
% sqrt(2*nu)*abs(x)/long
nx=@(nu,ll,xx) sqrt(2*nu).*abs(xx)./ll;
% first derivative
dnx=@(nu,ll,xx) sqrt(2*nu).*sign(xx)./ll;
% x^u*besselk
xbessel=@(nu,xx) xx.^nu.*besselk(nu,xx);
%first derivative of the previous function
dxbessel=@(nu,xx) -xx.^nu.*besselk(nu-1,xx);
%second derivative of the previous function
ddxbessel=@(nu,xx) -xx.^(nu-1).*besselk(nu-1,xx)+xx.^nu.*besselk(nu-2,xx);

%compute value of the function at points xx
coefS=2.^(1-lS)./gamma(lS);
xxN=nx(lS,lP,xx);
k=coefS.*xbessel(lS,xxN);

%check values close too zeros
II=abs(xx)<1e-50;
k(II)=1;

%compute first derivatives
if nbOut>1
    dxxN=dnx(lS,lP,xx);
    dk=coefS.*dxxN.*dxbessel(lS,xxN);
    %correction in 0
    dk(II)=0;
end

%compute second derivatives
if nbOut>2
    ddk=coefS.*dxxN.^2.*ddxbessel(lS,xxN);
    %correction in 0
    vdp=-lS(II).*gamma(lS(II)-1)./gamma(lS(II))./lP(II).^2;
    ddk(II)=vdp;
end
end
