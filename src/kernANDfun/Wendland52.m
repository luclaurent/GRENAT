%% Function: Wendland 5,3
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

function [k,dk,ddk]=wendland52(xx,para)

%number of output parameters
nbOut=nargout;

%number of design variables
nP=size(xx,2);
if nP~=1
    error(['Wrong number of hyperparameters (',mfilename,')']);
end

%extract length hyperparameters
lP=1./para(:,1);

%evaluation of the function
tc=xx./lP;
td=abs(tc);

%piecewise function
b1=1;
IX1=(td<b1);

%compute function
ev1=1-td;
ev2=16*tc.^2+7*td+1;
%
k=ev1.^7.*IX1.*ev2;

%compute first derivatives
if nbOut>1
    %
    sxx=sign(xx);
    %
    dev1=(-144*sxx.*tc.^2-24*tc)./lP;
    dk=dev1.*IX1.*ev1.^6;
end

%compute second derivatives
if nbOut>2
    %
    ddev1=(1152*tc.^2-120*td-24)./lP.^2;
    ddk=ddev1.*IX1.*ev1.^5;
end
end