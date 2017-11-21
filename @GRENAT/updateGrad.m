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

%% Update gradients (normalized if necessary)
% INPUTS:
% - newGrad: array of new gradients
% OUTPUTS:
% - gradOk: gradients ready to be stored

function gradOk=updateGrad(obj,newGrad)
%add gradients to the MissingData's object
obj.miss.addGrad(newGrad);
%add gradients to the NormRenorm's object
obj.norm.addGrad(newGrad);
%
if ~isempty(newGrad)
    if isempty(obj.grad)
        %first add new gradients
        gradOk=newGrad;
    else
        % concatenate gradients
        gradOk=[obj.grad;newGrad];
    end
    %
    initRunTrain(obj,true);
    initGradAvail(obj,true);
else
    Gfprintf('ERROR: Empty array of gradients\n');
end

