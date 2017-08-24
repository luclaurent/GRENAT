%% Method of KRG class
% L. LAURENT -- 07/08/2017 -- luc.laurent@lecnam.net

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
% - varargin: cell of objects/string/integer
% OUTPUTS:
% - none

function manageOpt(obj,varargin)
numel(varargin)
% fun=@(x)isa(x,'MissData');
% %look for the missing data class (MissData)
% sM=find(cellfun(fun,varargin)~=false);
% if ~isempty(sM);obj.missData=varargin{sM};end
% %look for the information concerning the metamodel (class initMeta)
% fun=@(x)isa(x,'initMeta');
% sM=find(cellfun(fun,varargin)~=false);
% if ~isempty(sM);obj.metaData=varargin{sM};end
% %look for the chosen kernel function (string)
% fun=@(x)ischar(x);
% sM=find(cellfun(fun,varargin)~=false);
% if ~isempty(sM);obj.kernelFun=varargin{sM};end
% %look for the chosen polynomial order (integer
% fun=@(x)(isnumeric(x));
% sM=find(cellfun(fun,varargin)~=false);
% if ~isempty(sM);obj.polyOrder=varargin{sM};end
end