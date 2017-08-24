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

%% Train the metamodel
% INPUTS:
% - none
% OUTPUTS:
% - none

function train(obj)
%display information before building
obj.showData('train');
%populate the surrogate model class
obj.dataTrain.addSample(obj.samplingN);
obj.dataTrain.addResp(obj.respN);
obj.dataTrain.addGrad(obj.gradN);
obj.dataTrain.manageOpt(obj.confMeta,obj.miss);
%train the metamodel
obj.dataTrain.train;
%save estimate parameters
if isprop(obj.dataTrain,'paraVal')
    obj.confMeta.definePara(obj.dataTrain.paraVal);
    obj.confMeta.updatePara;
end
%change state of flags
obj.runTrain=false;
obj.runErr=true;

% keyboard
% if metaData.norm.on&&~isempty(metaData.norm.resp.std)
%     ret.build.sig2=ret.build.sig2*metaData.norm.resp.std^2;
% end
end