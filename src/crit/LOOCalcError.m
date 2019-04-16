%% Function for calculating error of LOO (Cross-Validation)
% L. LAURENT -- 22/10/2012 -- luc.laurent@lecnam.net

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

function [ret]=LOOCalcError(Zref,Zap,variance,GZref,GZap,ns,np,LOO_norm)

%no norm specified
if nargin<8
    LOO_norm='L2';
end

%check availability of the gradients
availGrad=true;
if isempty(GZref)
    availGrad=false;
end
%check calculation of SCVR
availVar=true;
if isempty(variance)
    availVar=false;
end

%diff responses
diffZ=Zap-Zref;
if availGrad
    %diff gradients
    diffG=GZap-GZref;
end
%diff responses (choice of the norm)
switch LOO_norm
    case 'L1'
        diffC=abs(diffZ);
    case 'L2'
        diffC=diffZ.^2;
    case 'Linf'
        diffC=max(diffZ(:));
end
%Custom criterion
somm=0.5*(Zap+Zref);
ret.errp=1/ns*sum(abs(diffZ)./somm);
%PRESS
ret.press=sum(diffC);
%mean bias
ret.bm=1/ns*sum(diffZ);
if availGrad
    %diff gradients (choice of the norm)
    switch LOO_norm
        case 'L1'
            diffgc=abs(diffG);
        case 'L2'
            diffgc=diffZ.^2;
        case 'Linf'
            diffgc=max(diffG);
    end
    %mean of the differences on responsesn gradients and both squared
    ret.eloor=1/ns*sum(diffC);
    ret.eloog=1/(ns*np)*sum(diffgc(:));
    ret.eloot=1/(ns*(1+np))*(sum(diffC)+sum(diffgc(:)));
else
    %mean diff responses
    ret.eloor=1/ns*sum(diffC);
    ret.eloot=ret.eloor;
end
if availVar
    %criterion of adequation (SCVR Keane 2005/Jones 1998)
    ret.scvr=diffZ./variance;
    ret.scvr_min=min(ret.scvr(:));
    ret.scvr_max=max(ret.scvr(:));
    ret.scvr_mean=mean(ret.scvr(:));
    %%criterion of adequation (CAUTION of the norm!!!>> squared difference)
    diffA=diffC./variance;
    ret.adequ=1/ns*sum(diffA);
end
end