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


%% Remove missing data in matrix (responses+gradients)
% INPUTS:
% - V: input matrix 
% - type: type of removing ('':  default, 'f': force to remove for any size 
% of the input vector, 'n': remove data only for new added data)
% OUTPUTS:
% - VV: output matrix after removing data

function VV=removeGRM(obj,V,type)
%size of the input vector
sV=size(V);
%deal with no force parameter
if nargin<3;type='';end
%deal with different options (in type)
force=false;
sizS=obj.nS;
opt='';
switch type
    case {'f','F','force','Force','FORCE'}
        force=true;
        opt='f';
    case {'n','N','new','New','NEW'}
        sizS=obj.NnS;
        opt='n';
end
if (sV(1)==sizS*(obj.nP+1)&&sV(2)==sizS*(obj.nP+1))||force
    %split the matrix in four parts
    Va=V(1:sizS,1:sizS);
    Vb=V(1:sizS,sizS+1:end);
    Vbt=V(sizS+1:end,1:sizS);
    Vc=V(sizS+1:end,sizS+1:end);
    %
    VaR=obj.removeRM(Va,opt);
    VbR=obj.removeRV(obj.removeGV(Vb',opt)',opt);
    VbtR=obj.removeRV(obj.removeGV(Vbt,opt)',opt)';
    VcR=obj.removeGM(Vc,opt);
    %
    VV=[VaR VbR;VbtR VcR];
else
    VV=V;
    Gfprintf(' ++ Wrong size of the input matrix\n ++ |(%i,%i), expected: (%i,%i)|\n',sV(1),sV(2),sizS*(obj.nP+1),sizS*(obj.nP+1));
end
end