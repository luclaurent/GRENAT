%% Function: wavelet
%%L. LAURENT -- 21/03/2018 -- luc.laurent@lecnam.net

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

function [k,dk,ddk]=wavelet(xx,para)

%number of output parameters
nbOut=nargout;

%number of design variables
nP=size(xx,2);
if nP~=1
    error(['Wrong number of hyperparameters (',mfilename,')']);
end

%coefficient
a=1.75;

%extract length hyperparameters
lP=para(:,1);

%compute function value at point xx
te=abs(xx)./lP;
ca=cos(a*te);
td=exp(-te.^2/2);
k=ca.*td;


%compute first derivatives (bad definition)
if nbOut>1
    %
    sa=sin(a*te);
    dk=-td.*(a./lP.*sign(xx).*sa+xx./lP.^2.*ca);
end

%compute second derivatives (bad definition)
if nbOut>2
    ddk=td.*(2*te./lP.*sa+ca.*(te.^2./lP.^2-a^2./lP.^2-1./lP));
end
end