%% Display date and time
% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016  Luc LAURENT <luc.laurent@lecnam.net>
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

function dispDate(type)

day=clock;
if nargin==0
    fprintf('=============================================\n');
    fprintf('Date: %d/%d/%d   Time: %02.0f:%02.0f:%02.0f\n',...
        day(3), day(2), day(1), day(4), day(5), day(6));
    fprintf('=============================================\n');
else
    switch type
        case 'date'
            fprintf('==============\n');
            fprintf('Date: %d/%d/%d\n',...
                day(3), day(2), day(1));
            fprintf('==============\n');
        case 'time'
            fprintf('===============\n');
            fprintf('Time: %02.0f:%02.0f:%02.0f\n',...
                day(4), day(5), day(6));
            fprintf('===============\n');
    end
end
end