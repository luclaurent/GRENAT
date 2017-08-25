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

%% Show the gradients approximated by the metamodel
% INPUTS:
% - nbG: show specific component (optional, default: display all)
% OUTPUTS:
% - none

function showGrad(obj,nbG)
%default value
if nargin==1;nbG=1:size(obj.nonSampleGrad,3);end
for itG=nbG
    obj.confDisp.title=(['Approximated gradients /x' num2str(itG)]);
    displaySurrogate(obj.nonSamplePts,obj.nonSampleGrad(:,:,itG),obj.sampling,obj.resp,obj.grad,obj.confDisp);
end
end