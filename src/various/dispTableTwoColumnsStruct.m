%% Function for display the fields of a structure and the contents (only strings)
% L. LAURENT -- 20/08/2017 -- luc.laurent@lecnam.net

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

% INPUTS:
% - tableFieldIn: list of fieds (cell of strings)
% - structIn: structure composed by the fields of tableFieldIn
% OUTPUTS:
% - none

function dispTableTwoColumnsStruct(tableFieldIn,structIn)
%size of every components in tableA
sizeA=cellfun(@numel,tableFieldIn);
maxA=max(sizeA);
%space after each component
spaceA=maxA-sizeA+3;
spaceTxt=' ';
%display table
for itT=1:numel(tableFieldIn)
    if isfield(structIn,tableFieldIn{itT})
        fprintf('%s%s%s\n',tableFieldIn{itT},spaceTxt(ones(1,spaceA(itT))),structIn.(tableFieldIn{itT}));
    end
end
end
