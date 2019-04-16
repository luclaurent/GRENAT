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


%% Core of RBF computation using LU factorization
% INPUTS:
% - none
% OUTPUTS:
% - none

function coreLU(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LU factorization
[obj.matrices.LK,obj.matrices.UK,obj.matrices.PK]=lu(obj.K,'vector');
%
obj.matrices.iK=obj.matrices.UK\(obj.matrices.LK\obj.matrices.PK);
yL=obj.matrices.LK\obj.matrices.PK*obj.YYtot;
obj.W=obj.matrices.UK\yL;
%
end
