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

%% Show the confidence intervals approximated by the metamodel
% INPUTS:
% - ciVal: type of confidence interval (68, 95, 99)
% - nonsamplePts: give specific points
% OUTPUTS:
% - none

function showCI(obj,ciVal,nonsamplePts)
%type of confidence intervals
ciOk=false;ciValDef=95;
if nargin>1;if ~isempty(ciVal);if ismember(ciVal,[68,95,99]);ciOk=true;end, end, end
if ~ciOk;ciVal=ciValDef;end
%store non sample points
if nargin>2;obj.nonsamplePts=nonsamplePts;end
obj.confDisp.title=([num2str(ciVal) '% confidence intervals']);
%evaluation of the confidence interval
evalCI(obj);
%load data to display
ciDisp=obj.nonsampleCI.(['ci' num2str(ciVal)]);
%display the CI
displaySurrogateCI(obj.nonsamplePts,ciDisp,obj.confDisp,obj.nonsampleResp);
end