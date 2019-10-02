%% Method of MissData class
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


%% Check missing data in gradients (specified in input as NaN as component)
% INPUTS:
% - gradIn: array of gradients
% OUTPUTS:
% - iX: structure on which information about missing data is store

function iX=checkGrad(obj,gradIn)
%classical version
gradCheck=obj.grad;
runGrad=~obj.emptyGrad;
%version with input data
if nargin>1
    gradCheck=gradIn;
    runGrad=~isempty(gradCheck);
    
end
%
iX=[];
%
if runGrad
    %classical matrix of gradients
    obj.maskGrad=isnan(gradCheck);
    obj.nbMissGrad=sum(obj.maskGrad(:));
    [r,c]=find(obj.maskGrad==true);
    obj.ixMissGrad=[r c];
    [r,c]=find(obj.maskGrad==false);
    obj.ixAvailGrad=[r c];
    [ix]=find(obj.maskGrad'==true);
    obj.ixMissGradLine=ix;
    [ix]=find(obj.maskGrad'==false);
    obj.ixAvailGradLine=ix;
    %
    iX.maskGrad=obj.maskGrad;
    iX.nbMissGrad=obj.nbMissGrad;
    iX.ixMissGrad=obj.ixMissGrad;
    iX.ixAvailGrad=obj.ixAvailGrad;
    iX.ixMissGradLine=obj.ixMissGradLine;
    iX.ixAvailGradLine=obj.ixAvailGradLine;
    %
    if nargin==1
        obj.missGradAll=false;
        if obj.nbMissGrad==obj.nS*obj.nP;obj.missGradAll=true;end
        iX.missGradAll=obj.missGradAll;
    end
end
end
