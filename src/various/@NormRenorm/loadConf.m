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


%% Load existing information (defined using structure)
% INPUTS:
% - StClIn: input structure that contains the statistics data
% OUTPUTS:
% - none

function loadConf(obj,StClIn)
%read the input data
out=checkStCl(StClIn);
%
obj.meanN=out.meanN;
obj.meanR=out.meanR;
obj.meanS=out.meanS;
obj.stdN=out.stdN;
obj.stdR=out.stdR;
obj.stdS=out.stdS;
end