%% fonction: inverse multiquadratics
%L. LAURENT -- 17/01/2012 (r: 31/08/2015) -- luc.laurent@lecnam.net

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

function [k,dk,ddk]=invmultiqua(xx,para)

%number of output parameters
nbOut=nargout;

%number of design variables
nP=size(xx,2);
if nP~=1
    error(['Wrong number of hyperparameters (',mfilename,')']);
end

%extract length and smoothness hyperparameters
lP=1./para(:,1);

%compute function value at point xx
td=xx.^2./lP;
fd=1+td;
k=fd.^(-0.5);

%compute first derivatives
if nbOut>1
    %calcul derivees premieres
    dk=-xx./lP.^2.*fd.^(-1.5);
end

%compute second derivatives
if nbOut>2
    ddk=-fd.^(-1.5)./lP.^2+3*xx.^2./lP.^4.*fd.^(-2.5);
end
end
