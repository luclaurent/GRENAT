%% Method of xLS class
% L. LAURENT -- 31/07/2017 -- luc.laurent@lecnam.net

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


%% Regression matrix at the non-sample point
% INPUTS:
% - U: point used for evaluation
% OUTPUTS:
% - ff: values of the monomial terms at U
% - jf: values of the derivatives of the monomial terms at U

function [ff,jf]=buildMatrixNonS(obj,U)
calcGrad=false;
if nargout>1
    calcGrad=true;
end
if calcGrad
    [ff,jf]=multiMono(U,obj.funPoly);
else
    [ff]=multiMono(U,obj.funPoly);
end
