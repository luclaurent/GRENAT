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

%% Evaluate the CI of the metamodel
% INPUTS:
% - nonSamplePts: array of sample points (optional)
% OUTPUTS:
% - ci68,ci95,ci99: confidence intervals at 68%, 95% and 99%

function [ci68,ci95,ci99]=evalCI(obj,nonSamplePts)
%store non sample points
if nargin>1;
    obj.nonSamplePts=nonSamplePts;
    obj.eval;
end
%eval the CI
[ci68,ci95,ci99]=BuildCI(obj.nonSampleResp,obj.nonSampleVar);
obj.nonSampleCI.ci68=ci68;
obj.nonSampleCI.ci95=ci95;
obj.nonSampleCI.ci99=ci99;
end