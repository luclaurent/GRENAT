%% Function for calculating th right number of sample points for the reference grid
% used for evaluating the surrogate model (avoid to large number)
% L.LAURENT -- 15/05/2012 -- luc.laurent@lecnam.net

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

function nbV=initNbPts(dim)

if dim==1
    nbV=200;
elseif dim==2
    nbV=30;
elseif dim==3
    nbV=10;
elseif dim==4
    nbV=6;
elseif dim==5
    nbV=4;
elseif dim>=6
    nbV=3;  
else 
    Gfprintf('##############################\n');
    Gfprintf('### The dimension of the problem is too large:\n');
    Gfprintf('### Unable to generate the the right number of\n');
    Gfprintf('### sample points for the reference grid\n');
    Gfprintf(['### Define it manually (or See',mfilename,')\n'])
    Gfprintf('##############################\n');
    nbV=NaN;
end