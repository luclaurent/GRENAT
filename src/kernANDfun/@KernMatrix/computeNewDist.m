%% Method of KernMatrix class
% L. LAURENT -- 18/07/2017 -- luc.laurent@lecnam.net

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


%% Compute new inter-distances between sample points (after adding new sample points)
% INPUTS:
% - None
% OUTPUTS:
% - distN: array of inter-distances between new sample points
% - distNO: array of inter-distances between new and old sample points

function [distN,distNO]=computeNewDist(obj)
distN=obj.newSample(obj.NiX.iXsamplingN(:,1),:)-obj.newSample(obj.NiX.iXsamplingN(:,2),:);
distNO=obj.newSample(obj.NiX.iXsamplingNO(:,1),:)-obj.sampling(obj.NiX.iXsamplingNO(:,2),:);
obj.distN=distN;
obj.distNO=distNO;
end
