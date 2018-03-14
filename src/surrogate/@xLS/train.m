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


%% Building/training metamodel
% INPUTS:
% - flagRun: execute computation or not (optional, default true)
% OUTPUTS:
% - none

function train(obj,flagRun)
if nargin==1;flagRun=true;end
obj.showInfo('start');
%Prepare data
obj.setData;
%Build regression matrix (for the trend model)
%depending on the availability of the gradients
if ~obj.flagG
    obj.valFunPoly=multiMono(obj.sampling,obj.polyOrder);
    if obj.checkMiss
        %remove missing response(s)
        obj.valFunPoly=obj.missData.removeRV(obj.valFunPoly);
    end
else
    %gradient-based
    [MatX,MatDX]=multiMono(obj.sampling,obj.polyOrder);
    %remove lines associated to the missing data
    if obj.checkMiss
        obj.valFunPoly=obj.missData.removeRV(MatX);
        obj.valFunPolyD=obj.missData.removeGV(MatDX);
    else
        obj.valFunPoly=MatX;
        obj.valFunPolyD=MatDX;
    end
end
%compute regressors
obj.compute(flagRun);
if flagRun
    obj.showInfo('end');
else
    obj.showInfo('endPre');
end
end
