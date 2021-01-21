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

%% Show 2D results
% INPUTS:
% - none
% OUTPUTS:
% - none

function show2D(obj)
figure;
%
obj.confDisp.conf('ylabel','x_2');
%depend if the reference is available or not
if checkRef(obj)
    obj.nbSubplot=331;
    if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
    obj.confDisp.conf('samplePts',true);
    showRespRef(obj);
    obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
    showGradRef(obj,1);
    obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
    showGradRef(obj,2);
else
    obj.nbSubplot=231;
end
obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
obj.confDisp.conf('samplePts',true);
showResp(obj);
if obj.gradUsed
    obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
    showGrad(obj,1);
    obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
    showGrad(obj,2);
end
obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
error('')
showCI(obj,[]);
obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
obj.confDisp.conf('logScale',false);
showVar(obj);
obj.confDisp.conf('logScale',false);
obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
obj.confDisp.conf('logScale',false);
showEI(obj);
obj.confDisp.conf('logScale',false);
end
