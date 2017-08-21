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

%% Estimate internal parameters
% INPUTS:
% - none
% OUTPUTS:
% - none

function estimPara(obj)
fun=@(x)obj.sb(x,'estim');

obj.paraEstim=EstimPara(obj.nP,obj.metaData,fun);
obj.lVal=obj.paraEstim.l.Val;
obj.paraVal=obj.paraEstim.Val;
if isfield(obj.paraEstim,'p')
    obj.pVal=obj.paraEstim.p.Val;
end
if isfield(obj.paraEstim,'nu')
    obj.nuVal=obj.paraEstim.nu.Val;
end
end