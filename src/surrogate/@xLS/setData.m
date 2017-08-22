%% Method of xLS class
% L. LAURENT -- 31/07/2017 -- luc.laurent@lecnam.net

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


%% Prepare data for building (deal with missing data)
% INPUTS:
% - none
% OUTPUTS:
% - none

function setData(obj)
%Responses and gradients at sample points
YYT=obj.resp;
%remove missing response(s)
if obj.checkMiss
    YYT=obj.missData.removeRV(YYT);
end
%
der=[];
if obj.flagG
    tmp=obj.grad';
    der=tmp(:);
    %remove missing gradient(s)
    if obj.checkMiss
        der=obj.missData.removeGV(der);
    end
end
obj.YY=YYT;
obj.YYD=der;
end
