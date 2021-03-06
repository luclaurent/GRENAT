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


%% Compute variance
% INPUTS:
% - rr: correlation at the evaluation point
% - ff: monomial evaluated at the evaluation points
% OUTPUTS:
% - variance: value of the kriging variance

function variance=computeVariance(obj,rr,ff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute the prediction variance (MSE) (Lophaven, Nielsen & Sondergaard
%2004 / Marcelet 2008 / Chauvet 1999)
%
%depending on the factorization
switch obj.factK
    case 'QR'
        rrP=rr'*obj.matrices.PK;
        Qrr=obj.matrices.QtK*rr;
        u=obj.matrices.fcK*Qrr-ff';
        variance=obj.sig2*(1-(rrP/obj.matrices.RK)*Qrr+...
            u'/obj.matrices.fcCfct*u);
    case 'LU'
        rrP=rr(obj.matrices.PK,:);
        Lrr=obj.matrices.LK\rrP;
        u=obj.matrices.fcU*Lrr-ff';
        variance=obj.sig2*(1-(rr'/obj.matrices.UK)*Lrr+...
            u'/obj.matrices.fcCfct*u);
    case 'LL'
        Lrr=obj.matrices.LK\rr;
        u=obj.matrices.fcL*Lrr-ff';
        variance=obj.sig2*(1-(rr'/obj.matrices.LK')*Lrr+...
            u'/obj.matrices.fcCfct*u);
    otherwise
        rKrr=obj.matrices.KK \ rr;
        u=obj.matrices.fcC*rKrr-ff';
        variance=obj.sig2*(1+u'/obj.matrices.fcCfct*u - rr'*rKrr);
end
end
