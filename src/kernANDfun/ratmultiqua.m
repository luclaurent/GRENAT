%% fonction: rational multiquadratics
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

function [k,dk,ddk]=ratmultiqua(xx,para)

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
td=xx.^2./lP.^2;
tdd=1+td;
k=1-td./tdd;

%compute first derivatives
if nbOut>1
    %calcul derivees premieres
    dk=-2*xx./lP.^2./tdd.^2;
end

%compute second derivatives
if nbOut>2
    ddk=-(2*tdd.^2./lP.^2-8*td.*tdd./lP.^2)./tdd.^4;
end
end
