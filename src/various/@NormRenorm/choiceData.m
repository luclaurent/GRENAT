%% Method of NormRenorm class
% L. LAURENT -- 02/08/2017 -- luc.laurent@lecnam.net

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


%% Choice of the current normalization data
% INPUTS:
% - type: kind of input data: sampling, responses or normal (use current statistics data) (optional)
% OUTPUTS:
% - flag: flag as false since no statistics data can be loaded

function flag=choiceData(obj,type)
flag=true;
%in the case of no type specified
if nargin<2;type='normal';end
switch type
    case {'resp','Resp','r','R','RESP','response','Responses','RESPONSES'}
        obj.meanC=obj.meanR;
        obj.stdC=obj.stdR;
    case {'sampling','Sampling','s','S','SAMPLING'}
        obj.meanC=obj.meanS;
        obj.stdC=obj.stdS;
    otherwise
        obj.meanC=obj.meanN;
        obj.stdC=obj.stdN;
end
% if empty normalization data
if isempty(obj.meanC)||isempty(obj.stdC)
    Gfprintf(' ++ Caution: normalization data not defined (type: %s)\n',type);
    flag=false;
end
end