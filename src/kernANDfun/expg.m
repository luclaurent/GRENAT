%% fonction: exponentielle generalisee
%% L. LAURENT -- 03/04/2018 -- luc.laurent@lecnam.net

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


function [k,dk,ddk]=expg(xx,para)

%number of output parameters
nbOut=nargout;

%number of design variables
nP=size(xx,2);
if nP~=1
    error(['Wrong number of hyperparameters (',mfilename,')']);
end

%extract length hyperparameters
lP=1./para(:,1);
pow=para(:,2);

%evaluation of the function
axx=abs(xx);
td=axx.^pow./lP;
%
k=exp(-td);

%compute first derivatives
if nbOut>1
    %    
    dk=-pow./lP.*sign(xx).*axx.^(pow-1).*k;
end

%compute second derivatives
if nbOut>2
    %
    ddk=k.*(pow.^2./lP.^2.*axx.^(2.*pow-2)-pow.*(pow-1)./lP.*axx.^(pow-2));
end
end
