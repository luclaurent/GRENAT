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


%% Check missing data in responses (specified in input as NaN)
% INPUTS:
% - respIn: vector of responses
% OUTPUTS:
% - iX: structure on which information about missing data is store

function iX=checkResp(obj,respIn)
respCheck=obj.resp;
if nargin>1
    respCheck=respIn;
end
%look for missing data in responses
obj.maskResp=isnan(respCheck);
obj.nbMissResp=sum(obj.maskResp);
obj.ixMissResp=find(obj.maskResp==true);
obj.ixAvailResp=find(obj.maskResp==false);
%
iX.maskResp=obj.maskResp;
iX.nbMissResp=obj.nbMissResp;
iX.ixMissResp=obj.ixMissResp;
iX.ixAvailResp=obj.ixAvailResp;
iX.nbMissResp=obj.nbMissResp;
%
if nargin==1
    obj.missRespAll=false;
    if obj.nbMissResp==obj.nS;obj.missRespAll=true;end
    iX.missRespAll=obj.missRespAll;
end

end