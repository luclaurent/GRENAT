%% Method of GRENAT class
% L. LAURENT -- 26/06/2016 -- luc.laurent@lecnam.net

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

%% Set the type of metamodel in the configuration and initialize
% the metamodel
% INPUTS:
% - typeIn: raw name of the gradients
% OUTPUTS:
% - none

function setTypeConf(obj,typeIn)
obj.confMeta.type=typeIn;
%extract the right type of metamodel
[InGrad,ClassGrad,typeOk]=obj.checkGE(typeIn);
%initialize the metamodel
obj.dataTrain=eval(typeOk);
%for gradient-based approximation
if InGrad||ClassGrad
    obj.gradUsed=true;
end
end