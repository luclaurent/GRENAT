%% Method of GRENAT class
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

%% Check if all data is available for displaying the reference
% INPUTS:
% - none
% OUTPUTS:
% - okAll: evertything is ok
% - okSample: the points are ok
% - okResp: the responses are ok
% - okGrad: the gradients are ok

function [okAll,okSample,okResp,okGrad]=checkRef(obj)
okSample=false;
okResp=false;
okGrad=false;
nbSRef(1)=size(obj.sampleRef,1);
nbSRef(2)=size(obj.sampleRef,2);
nbSRef(3)=size(obj.sampleRef,3);
nbRRef(1)=size(obj.respRef,1);
nbRRef(2)=size(obj.respRef,2);
nbRRef(3)=size(obj.respRef,3);
nbGRef(1)=size(obj.gradRef,1);
nbGRef(2)=size(obj.gradRef,2);
nbGRef(3)=size(obj.gradRef,3);
if sum(nbSRef(:))~=0
    okSample=true;
    if nbSRef(1)==nbRRef(1)
        okResp=true;
    end
    if nbGRef(3)==1
        if nbGRef(1)==nbSRef(1)&&nbGRef(2)==nbSRef(2)
            okGrad=true;
        end
    elseif nbGRef(3)==nbSRef(2)&&nbGRef(1)==nbSRef(1)
        okGrad=true;
    elseif all(nbGRef==nbSRef)
        okGrad=true;
    end
end
okAll=okSample&&okResp&&okGrad;
%display error messages
if ~okSample;Gfprintf('>> Wrong definition of the reference sample points\n');end
if ~okResp;Gfprintf('>> Wrong definition of the reference responses\n');end
if ~okGrad;Gfprintf('>> Wrong definition of the reference gradients\n');end
end