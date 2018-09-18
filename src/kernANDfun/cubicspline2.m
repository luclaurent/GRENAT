%% Fonction: Cubic Spline 2
% L. LAURENT -- 03/04/2018 -- luc.laurent@lecnam.net

%ref: B. A. Lockwood and M. Anitescu. Gradient-enhanced universal kriging for uncertainty propagation. Nuclear Science and Engineering, 170(2):168?195, feb 2012.

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

function [k,dk,ddk]=cubicspline2(xx,para)

%number of output parameters
nbOut=nargout;

%number of design variables
nP=size(xx,2);
if nP~=1
    error(['Wrong number of hyperparameters (',mfilename,')']);
end

%coefficients
a=6;
b=6;
c=2;

%extract length hyperparameters
lP=1./para(:,1);

%evaluation of the function
tc=xx./lP;
td=abs(tc);

%piecewise function
b1=0;b2=0.5;b3=1;
IX1=(b1<=td).*(td<b2);
IX2=(b2<=td).*(td<b3);

%compute function
ev1=1-a.*td.^2+b.*td.^3;
ev2=c*(1-td).^3;
%
k=ev1.*IX1+ev2.*IX2;

%compute first derivatives
if nbOut>1
    %    
    sxx=sign(xx);
    %
    dev1=-2*a*tc./lP+3*b*sxx.*tc.^2./lP;
    dev2=-c*3*sxx.*(1-td).^2./lP;
    dk=dev1.*IX1+dev2.*IX2;
end

%compute second derivatives
if nbOut>2
    %
    ddev1=-2*a./lP.^2+6*b*td./lP.^2;
    ddev2=c*6*(1-td)./lP.^2;
    ddk=ddev1.*IX1+ddev2.*IX2;
end