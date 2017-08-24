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

%% Show 1D results
% INPUTS:
% - none
% OUTPUTS:
% - none

function show1D(obj)
figure;
%depend if the reference is available or not
if checkRef(obj)
    obj.nbSubplot=231;
    if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
    obj.confDisp.conf('samplePts',true,'sampleGrad',false);
    showRespRef(obj);
    obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
    %remove display of sample points
    obj.confDisp.conf('samplePts',true,'sampleGrad',true);
    showGradRef(obj);
    obj.nbSubplot=obj.nbSubplot+1;
else
    obj.nbSubplot=221;
end
obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
obj.confDisp.conf('samplePts',true,'sampleGrad',false);
showResp(obj);
obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
%remove display of sample points
obj.confDisp.conf('samplePts',true,'sampleGrad',true);
showGrad(obj);
obj.nbSubplot=obj.nbSubplot+1;if ~obj.confDisp.newFig;subplot(obj.nbSubplot);end
showCI(obj,[]);
end