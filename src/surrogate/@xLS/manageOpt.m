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


%% Function for dealing with the the input arguments of the class
% INPUTS:
% - optiIn: object of class MissData or initMeta
% OUTPUTS:
% - flagR: return the value of a boolean is proposed (if not return true)

function flagR=manageOpt(obj,varargin)
%
flagR=true; %default
%
fun=@(x)isa(x,'MissData');
%look for the missing data class (MissData)
sM=find(cellfun(fun,optIn)~=false);
if ~isempty(sM);obj.missData=optIn{sM};end
%look for a boolean
fun=@(x)islogical(x);
sM=find(cellfun(fun,optIn)~=false);
if ~isempty(sM);flagR=optIn{sM};end
end