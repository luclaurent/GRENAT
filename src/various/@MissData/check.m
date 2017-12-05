%% Method of MissData class
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


%% Check database and display
% INPUTS:
% - type: type of checking ('r' for responses, 'g' for gradients)
% OUTPUTS:
% - none

function check(obj,type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Gfprintf(' >> Check missing data: ');
%
checkForceResp=false;
checkForceGrad=false;
checkManu=false;
%
if nargin>1
    checkManu=true;
    switch type
        case 'r'
            checkForceResp=true;
        case 'g'
            checkForceGrad=true;
    end
end
%
if (obj.requireCheckResp&&~checkManu)||(checkManu&&checkForceResp)
    fprintf('Responses ');
    obj.checkResp();
    obj.requireCheckResp=false;
end
if (obj.requireCheckGrad&&~checkManu)||(checkManu&&checkForceGrad)
    fprintf('Gradients');
    obj.checkGrad();
    obj.requireCheckGrad=true;
end
fprintf('\n');
obj.show();
end
