%% Method of MissData class
% L. LAURENT -- 02/08/2017 -- luc.laurent@lecnam.net

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


%% Remove missing data in matrix (responses)
% INPUTS:
% - V: input matrix 
% - type: type of removing ('':  default, 'f': force to remove for any size 
% of the input matrix, 'n': remove data only for new added data)
% OUTPUTS:
% - VV: output matrix after removing data

function VV=removeRM(obj,V,type)
%size of the input matrix
sV=size(V);
%deal with no force parameter
if nargin<3;type='';end
%deal with different options (in type)
force=false;
sizS=obj.nS;
maskC=obj.ixMissResp;
switch type
    case {'f','F','force','Force','FORCE'}
        force=true;
    case {'n','N','new','New','NEW'}
        sizS=obj.NnS;
        maskC=obj.newResp.ixMissResp;
end
if (sV(1)==sizS&&sV(2)==sizS)||force
    VV=V;
    VV(maskC,:)=[];
    VV(:,maskC)=[];
else
    VV=V;
    Gfprintf(' ++ Wrong size of the input square matrix\n ++ |(%i,%i), expected: (%i,%i)| (or use force)\n',sV(1),sV(2),sizS,sizS);
end
end