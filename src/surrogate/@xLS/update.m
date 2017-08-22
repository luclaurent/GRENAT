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


%% Update metamodel
% INPUTS:
% - newSample: new sample points
% - newResp: new response
% - newGrad: new gradients
% - newMissData: information concerning the missing data at the new points
% OUTPUTS:
% - none

function update(obj,newSample,newResp,newGrad,newMissData)
obj.showInfo('update');
%add new sample, responses and gradients
obj.addSample(newSample);
obj.addResp(newResp);
if nargin>3;obj.addGrad(newGrad);end
if nargin>4;obj.missData=newMissData;end
if nargin<4;newGrad=[];end
%update the data and compute
obj.trainUpdate(newSample,newResp,newGrad);
obj.showInfo('end');
end

