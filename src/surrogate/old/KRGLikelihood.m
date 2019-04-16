%% Function for computing Likelihood and Log-likelihood of the krigind
%L. LAURENT -- 10/11/2010 -- luc.laurent@lecnam.net
%
% //!\\ specific process for evaluating the logarithm of the determinant
%in order to reduce computational  issues

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

function [logLi,Li,liSack]=KRGLikelihood(dataKRG)

%size of the kernel matrix
sizeK=size(dataKRG.build.KK,1);

%computation of the log-likelihood (Jones 1993 / Leary 2004)
switch dataKRG.build.factKK
    case 'QR'
        diagRK=diag(dataKRG.build.RK);
        detK=abs(prod(diagRK)); %Q is an unitary matrix
        logDetK=sum(log(abs(diagRK)));
    case 'LL'
        diagLK=diag(dataKRG.build.LK);
        detK=prod(diagLK)^2;
        logDetK=2*sum(log(abs(diagLK)));
    case 'LU'
        diagUK=diag(dataKRG.build.UK);
        detK=prod(diagUK); %L is a quasi-triangular matrix and contains ones on the diagonal
        logDetK=sum(log(abs(diagUK)));
    otherwise
        eigVal=eig(dataKRG.build.K);
        detK=prod(eigVal);
        logDetK=sum(log(eigVal));
end

logLi=sizeK/2*log(2*pi*dataKRG.build.sig2)+1/2*logDetK+sizeK/2;
liSack=0;
if nargout==3
    liSack=abs(detK)^(1/sizeK)*dataKRG.build.sig2;
end


if isinf(logLi)||isnan(logLi)
    logLi=1e16;
end

if nargout>=2
    %computation of the likelihood (Jones 1993 / Leary 2004)
    Li=1/((2*pi*dataKRG.build.sig2)^(sizeK/2)*sqrt(detK))*exp(-sizeK/2);
    
elseif nargout >3
    error(['Wrong number of output variables (',mfilename,')\n']);
end
