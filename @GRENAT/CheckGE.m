%% Static method of GRENAT class
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

%% Function for checking if the surrogate model is a classical
%gradient-enhanced or indirect gradient-enhanced surrogate model
% INPUTS:
% - typeSurrogate: raw name of the chosen surrogate
% OUTPUTS:
% - Indirect: flag for indirect gradient-enhanced metamodel
% - Classical: flag for classical gradient-enhanced metamodel
% - typeOk: right name of the surrogate model

function [Indirect,Classical,typeOk]=CheckGE(typeSurrogate)
%check Indirect
nn=regexp(typeSurrogate,'^In','ONCE');
Indirect=~isempty(nn);
%check gradient-enhanced
nn=regexp(typeSurrogate,'^G','ONCE');
Classical=~isempty(nn);
% remove letter(s)
iX=1;
if Indirect
    iX=3;    
end
if Classical
    iX=2;    
end
typeOk=typeSurrogate(iX:end);
end