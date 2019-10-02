%% Method of xLS class
% L. LAURENT -- 07/11/2018 -- luc.laurent@lecnam.net

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


%% Define polynomial function (or build it if the function is not available)
% INPUTS (if arguments are precised, two must be given):
% - polyOrder: order of the polynomial (optional)
% - nP: number of parameters (optional)
% OUTPUTS:
% - none

function buildFunPoly(obj,polyOrder,nP)
if nargin<3
    polyOrder=obj.polyOrder;
    nP=obj.nP;
end

%choose polynomial function
obj.funPoly=['mono_' num2str(polyOrder,'%02i') '_' num2str(nP,'%03i')];
%check if the function exist (if not create it)
if ~exist(obj.funPoly,'file')
    toolGeneMonomial(polyOrder,np);
end
end