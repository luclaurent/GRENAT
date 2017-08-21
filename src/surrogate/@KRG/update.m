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


%% Update metamodel and train it
% INPUTS:
% - newSample: array of new sample points
% - newResp: vector of new responses
% - newGrad: array of new gradients
% - newMissData: new missing data
% OUTPUTS:
% - none

%% Update metamodel
function update(obj,newSample,newResp,newGrad,newMissData)
obj.showInfo('update');
obj.fCompute;
%add new sample, responses and gradients
obj.addSample(newSample);
obj.addResp(newResp);
if nargin>3;obj.addGrad(newGrad);end
if nargin>4;obj.missData=newMissData;end
if nargin<4;newGrad=[];end
%update the data and compute
obj.trainUpdate(newSample,newResp,newGrad);
end
