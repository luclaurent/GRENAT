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


%% Building/training the updated metamodel
% INPUTS:
% - samplingIn: new sample points
% - respIn: new response
% - gradIn: new gradients
% OUTPUTS:
% - none

function trainUpdate(obj,samplingIn,respIn,gradIn)
%Prepare data
obj.updateData(respIn,gradIn);
%Build regression matrix (for the trend model)
%
%depending on the availability of the gradients
if ~obj.flagG
    newVal=multiMono(samplingIn,obj.polyOrder);
    if obj.checkNewMiss
        %remove missing response(s)
        newVal=obj.missData.removeRV(newVal,'n');
    end
    obj.valFunPoly=[obj.valFunPoly;newVal];
else
    %gradient-based
    [MatX,MatDX]=multiMono(samplingIn,obj.polyOrder);
    %remove lines associated to the missing data
    if obj.checkNewMiss
        MatX=obj.missData.removeRV(MatX,'n');
        MatDX=obj.missData.removeGV(MatDX,'n');
    end
    obj.valFunPoly=[obj.valFunPoly;MatX];
    obj.valFunPolyD=[obj.valFunPolyD;MatDX];
end
%compute regressors
obj.compute();
end
