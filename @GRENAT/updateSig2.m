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

%% Update variance (renormalized if necessary)
% INPUTS:
% - newVar: value of variance
% OUTPUTS:
% - none

function updateSig2(obj,newVar)
%
if ~isempty(newVar)    
    % renormalize the new variance using the existing database
    if obj.confMeta.normOn
        varOk=obj.norm.reNormVar(newVar);
    else
        varOk=newVar;
    end
    %store data
    obj.sig2=varOk;
else
    obj.sig2=[];
end
end

