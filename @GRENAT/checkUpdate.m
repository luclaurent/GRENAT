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

%% Check if update could be done
% responses and gradients
% INPUTS:
% - flag: flag for for forcing update
% OUTPUTS:
% - s: status of the update

function s=checkUpdate(obj)
s=false;
obj.requireUpdate=false;
%load folder of GRENAT
f=fileparts(mfilename('fullpath'));
if ismac||isunix
    if exist(fullfile('.git'),'dir')
        [e,~]=system(['cd ' f ' && git status -uno | grep up-to-date && exit 3']);
        if e==3
            Gfprintf('GRENAT is up to date\n');
        else
            Gfprintf('GRENAT could be updated\n');
            s=true;
            obj.requireUpdate=true;
        end
    else
        Gfprintf('Not a git version: checking update not available\n');
    end
else
    Gfprintf('Not a linux or mac computer: checking update not available\n');
end
end