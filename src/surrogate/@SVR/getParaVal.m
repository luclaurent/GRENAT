%% Method of SVR class
% L. LAURENT -- 18/08/2017 -- luc.laurent@lecnam.net

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

%% Get value of the internal parameters
% INPUTS:
% - none
% OUTPUTS:
% - pV: value of the hyperparameters

function pV=getParaVal(obj)
if isempty(obj.paraVal)
    %w/o estimation, the initial values of hyperparameters are chosen
    switch obj.kernelFun
        case {'expg','expgg'}
            obj.paraVal=[obj.metaData.para.l.Val obj.metaData.para.p.Val];
        case {'matern'}
            obj.paraVal=[obj.metaData.para.l.Val obj.metaData.para.nu.Val];
        otherwise
            obj.paraVal=obj.metaData.para.l.Val;
    end
end
pV=obj.paraVal;
end