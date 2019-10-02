%% Function: spherical
%%L. LAURENT -- 11/05/2010 (r: 31/08/2015) -- luc.laurent@lecnam.net

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

function [k,dk,ddk]=spherical(xx,para)

%number of output parameters
nbOut=nargout;

%number of design variables
nP=size(xx,2);
if nP~=1
    error(['Wrong number of hyperparameters (',mfilename,')']);
end

%coefficient
a=3/2;
b=0.5;

%extract length and smoothness hyperparameters
lP=1./para(:,1);

%find vlaues of xx larger than para
iXS=(abs(xx)>lP);

%compute function value at point xx
td=abs(xx)./lP;
k=1-a*td+b*td.^3;

%correction
k(iXS)=0;

%compute first derivatives (bad definition)
if nbOut>1
    %
    dk=a*sign(xx)./lP.*(td.^2-1);
    %correction
    dk(iXS)=0;
end

%compute second derivatives (bad definition)
if nbOut>2
    ddk=2*a*td./lP.^2;
    %correction
    ddk(iXS)=0;
end
end