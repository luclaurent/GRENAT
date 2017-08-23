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

%% Compute infill criterion
% INPUTS:
% - nonsamplePts: array of sample points (optional)
% - Verb: activate or not the verbose mode (optional)
% OUTPUTS:
% - ZI: value(s) of the chosen infill criteria
% - detI: details concerning infill

function [ZI,detI]=evalInfill(obj,nonsamplePts,Verb)
if nargin<3;Verb=true;end
%store non sample points
if nargin>1;obj.nonsamplePts=nonsamplePts;end
%evaluation
obj.eval([],Verb);
%minimum response
respMin=min(obj.resp);
%computation of infill criteria
ZI=[];
if ~isempty(obj.nonsampleVar)
    [ZI,detI]=InfillCrit(respMin,obj.nonsampleResp,obj.nonsampleVar,obj.confMeta.infill);
end
end