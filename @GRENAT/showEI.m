%% Method of GRENAT class
% L. LAURENT -- 06/11/2018 -- luc.laurent@lecnam.net

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

%% Show the infill criterion provided by the metamodel
% INPUTS:
% - none
% OUTPUTS:
% - none

function showEI(obj)
if ~isempty(obj.nonSampleEI)
    obj.confDisp.title=('Infill criterion (EI)');
    displaySurrogate(obj.nonSamplePts,obj.nonSampleEI,[],obj.sampling,obj.resp*0,[],obj.confDisp);
    if isfield(obj.detInfill,'exploitEI')
        displaySurrogate(obj.nonSamplePts,obj.detInfill.exploitEI,[],obj.sampling,obj.resp*0,[],obj.confDisp);
    end
    if isfield(obj.detInfill,'explorEI')
        displaySurrogate(obj.nonSamplePts,obj.detInfill.explorEI,[],obj.sampling,obj.resp*0,[],obj.confDisp);
    end
end
end