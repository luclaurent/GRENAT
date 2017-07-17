%% Function: squared exponential
%%L. LAURENT -- 18/01/2012 -- luc.laurent@cnam.fr
%revision of the 13/11/2012
%change of the 19/12/2012: change correlation length
%revision of the 31/08/2015: change of the name of the function
%change of the 02/05/2016: change to unidimensional function
%
%Rasmussen 2006 p. 83

%     GRENAT - GRadient ENhanced Approximation Toolbox 
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016  Luc LAURENT <luc.laurent@lecnam.net>
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

function [k,dk,ddk]=sexp(xx,para)
%number of output parameters
nbOut=nargout;
%check hyperparameters
nP=size(para,2);
if nP~=1
    error(['Wrong number of hyperparameters (',mfilename,')']);
end

%extract length and smoothness hyperparameters
lP=1./para(:,1);

%compute value of the function at point xx
td=-xx.^2./lP.^2/2;
k=exp(td);

%compute first derivatives
if nbOut>1
    %calcul derivees premieres
    dk=-xx./lP.^2.*k;
end

%compute second derivatives
if nbOut>2
    ddk=(xx.^2./lP.^4-1./lP.^2).*k;
end
end
