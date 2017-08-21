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


%% Building/training the updated metamodel
% INPUTS:
% - samplingIn: array of sample points
% - respIn: vector of responses
% - gradIn: array of gradients
% OUTPUTS:
% - none

%% Building/training the updated metamodel
function trainUpdate(obj,samplingIn,respIn,gradIn)
%Prepare data
obj.updateData(samplingIn,respIn,gradIn);
% estimate the internal parameters or not
if obj.estimOn
    obj.estimPara;
else
    obj.compute;
end
%
obj.requireCompute=false;
%
obj.showInfo('end');
%
obj.cv();
%
if obj.metaData.cvDisp
    obj.showCV();
end
end
