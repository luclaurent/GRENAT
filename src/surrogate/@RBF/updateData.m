%% Method of RBF class
% L. LAURENT -- 15/08/2017 -- luc.laurent@lecnam.net

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


%% Update data for building (deal with missing data)
% INPUTS:
% - samplingIn: array of sample points
% - respIn: vector of responses
% - gradIn: array of gradients
% OUTPUTS:
% - none

function updateData(obj,samplingIn,respIn,gradIn)
%Responses and gradients at sample points
YYT=respIn;
%remove missing response(s)
if obj.checkNewMiss
    YYT=obj.missData.removeRV(YYT,'n');
end
%
der=[];
if obj.flagG
    tmp=gradIn';
    der=tmp(:);
    %remove missing gradient(s)
    if obj.checkNewMiss
        der=obj.missData.removeGV(der,'n');
    end
end
obj.YY=[obj.YY;YYT];
obj.YYD=[obj.YYD;der];
%
obj.YYtot=[obj.YY;obj.YYD];
%initialize kernel matrix
obj.kernelMatrix.updateMatrix(samplingIn);
end
