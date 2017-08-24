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

%% Show results
% INPUTS:
% - varargin: specific options for the configuration of the display
% OUTPUTS:
% - none

function show(obj,varargin)
%depending of the kind of data
if obj.sizeNonSample(3)==2
    obj.confDisp.conf('d3',true,'contour',true);
    %if argument
    if nargin>1;obj.confDisp.conf(varargin{:});end
    show2D(obj);
elseif obj.sizeNonSample(3)==1
    obj.confDisp.conf('d3',false,'d2',false);
    %if argument
    if nargin>1;obj.confDisp.conf(varargin{:});end
    show1D(obj);
end
end
