%% Method of RBF class
% L. LAURENT -- 15/08/2017 -- luc.laurent@lecnam.net

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


%% Core of RBF computation using QR factorization
% INPUTS:
% - none
% OUTPUTS:
% - none

function coreQR(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QR factorization
[obj.matrices.QK,obj.matrices.RK,obj.matrices.PK]=qr(obj.K);
%
obj.matrices.iK=obj.matrices.PK*(obj.matrices.RK\obj.matrices.QK');
yQ=obj.matrices.QK'*obj.YYtot;
obj.W=obj.matrices.PK*(obj.matrices.RK\yQ);
%
end
