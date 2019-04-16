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


%% Show information in the console
% INPUTS:
% - type: kind of display (start, end, update, cv, end)
% OUTPUTS:
% - none

function showInfo(obj,type)
switch type
    case {'start','START','Start'}
        textd=' ++ Type: ';
        textf='';
        Gfprintf('\n%s\n',[textd 'Least-Squares ((G)LS)' textf]);
        Gfprintf('>> Deg : %i \n',obj.polyOrder);
        %
        %if dispTxtOnOff(obj.cvOn,'>> CV: ',[],true)
        %    dispTxtOnOff(obj.cvFull,'>> Computation all CV criteria: ',[],true);
        %    dispTxtOnOff(obj.cvDisp,'>> Show CV: ',[],true);
        %end
        %
        %Gfprintf('\n');
    case {'update'}
        Gfprintf(' ++ Update xLS\n');
    case {'cv','CV'}
    case {'end','End','END'}
        Gfprintf(' ++ END building xLS\n');
    case {'endPre','EndPre','ENDPRE'}
        Gfprintf(' ++ END pre-building xLS\n');
end
end
