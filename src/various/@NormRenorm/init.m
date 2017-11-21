%% Method of NormRenorm class
% L. LAURENT -- 02/08/2017 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017-2017  Luc LAURENT <luc.laurent@lecnam.net>
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


%% Initialize all data
% INPUTS:
% - none
% OUTPUTS:
% - none

function init(obj,type)
if nargin==1
    listP={'meanC','stdC','meanN','stdN','stdR','meanR','stdS','meanS','respN','samplingN','gradN'};
else
    switch type
        case {'d','D','data','DATA','Data'}
            listP={'respN','samplingN','gradN'};
        case {'r','R','responses','resp','RESP','RESPONSES','Resp','Responses'}
            listP={'stdR','meanR','respN','gradN'};
        case {'s','S','sampling','samp','Samp','SAMP','SAMPLING'}
            listP={'stdS','meanS','samplingN','gradN'};
    end
end
for it=1:length(listP)
    feval([obj '.' listP{it} '=[];']);
end
end