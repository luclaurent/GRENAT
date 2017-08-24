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

%% Update responses (normalized if necessary)
% INPUTS:
% - newResp: vector of new responses
% OUTPUTS:
% - respOk: responses ready to be stored

function respOk=updateResp(obj,newResp)
%add responses to the MissingData's object
obj.miss.addResp(newResp);
%
if ~isempty(newResp)
    if isempty(obj.resp)
        %first add of responses
        respOk=newResp;
        %add responses to the NormRenorm's object if normalization is required
        if obj.confMeta.normOn
            obj.respN=obj.norm.addResp(obj.resp);
        else
            obj.respN=obj.resp;
        end        
    else
        %concatenate responses
        respOk=[obj.resp;newResp];
        % normalize the new responses using the existing database
        if obj.confMeta.normOn
            obj.respN=[obj.respN;obj.norm.Norm(newResp,'r')];
        else
            obj.respN=[obj.respN;obj.resp];
        end
    end
    %
    initRunTrain(obj,true);
else
    Gfprintf('ERROR: Empty array of responses\n');
end


