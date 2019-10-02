%% Function: wave
%L. LAURENT -- 20/03/2018 -- luc.laurent@lecnam.net

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

function [k,dk,ddk]=wave(xx,para)

%number of output parameters
nbOut=nargout;

%number of design variables
nP=size(xx,2);
if nP~=1
    error(['Wrong number of hyperparameters (',mfilename,')']);
end

%extract length and smoothness hyperparameters
lP=1./para(:,1);

%find null values in xx
iXNull=(xx==0);

%compute function value at point xx
td=abs(xx)./lP;
k=sin(td)./td;
%precise specific value at xx=0
k(iXNull)=1;


%compute first derivatives
if nbOut>1
    %
    dk=cos(td)./xx-sign(xx).*lP./xx.^2.*sin(td);
end

%compute second derivatives
if nbOut>2
    ddk=-cos(td)./xx.^2+sign(xx)./xx.*sin(td).*(2*lP./xx-1./lP);
end
end
