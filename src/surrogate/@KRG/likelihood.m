%% Method of KRG class
% L. LAURENT -- 07/08/2017 -- luc.laurent@lecnam.net

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


%% Compute likelihood
% INPUTS:
% - paraValIn: values of the hyperparameters
% OUTPUTS:
% - logLi: log likelihood
% - Li: likelihood
% - liSack: likelihood from formula of Sacks 1989

function [logLi,Li,liSack]=likelihood(obj,paraValIn)
if nargin==1;paraValIn=obj.paraVal;end
%compute matrices
[detK,logDetK]=obj.compute(paraValIn);
%size of the kernel matrix
sizeK=size(obj.K,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%computation of the log-likelihood (Jones 1993 / Leary 2004)
logLi=sizeK/2*log(2*pi*obj.sig2)+1/2*logDetK+sizeK/2;
if nargout>=2
    %computation of the likelihood (Jones 1993 / Leary 2004)
    Li=1/((2*pi*obj.sig2)^(sizeK/2)*sqrt(detK))*exp(-sizeK/2);
end
%computation of the log-likelihood from Sacks 1989
if nargout==3
    liSack=abs(detK)^(1/sizeK)*obj.sig2;
end
if isinf(logLi)||isnan(logLi)
    logLi=1e16;
end
end
