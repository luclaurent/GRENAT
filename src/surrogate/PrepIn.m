%% Preparation for Indirect Gradient-Enhanced Surrogate Models
% L. LAURENT -- 26/04/2016 -- luc.laurent@lecnam.net

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

function [newSampling,newResp]=PrepIn(samplingIn,respIn,gradIn,metaData,missData)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display information about the function
Gfprintf('>>> Preparation of data for Indirect Gradient-Based Surrogate Models  \n');

%dimension of the problem (number of parameters)
np=size(samplingIn,2);
% initial number of sample points
ns_init=size(samplingIn,1);

%if missing data is considered
if ~nargin==5
    missData.onResp=false;
    missData.onGrad=false;
end

%with respect with the kind of gradient data
Gfprintf(' >> Step of the Taylor expansion (manu):');
fprintf(' %d',metaData.para.stepTaylor);
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create new points (1 per direction)
%manage Taylor's step
if numel(metaData.para.stepTaylor)~=np
    stepTaylor=metaData.para.stepTaylor(1)*ones(1,np);
else
    stepTaylor=metaData.para.stepTaylor;
end

%Reordering sampled points and duplicates
reordS=reshape(samplingIn',1,[]);
dupS=repmat(reordS,np+1,1);
%create shift per direction
matStep=diag(stepTaylor);
matStepDup=[zeros(1,np*ns_init);repmat(matStep,1,ns_init)];
badordS=dupS+matStepDup;
newSampling=zeros((np+1)*ns_init,np);

%new points
for ii=1:np
    li=ii:np:(np*ns_init);
    newSampling(:,ii)=reshape(badordS(:,li),(np+1)*ns_init,[]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Cleaning if missing data (Caution in the case of missing response, the
%%% the associated gradients is also removed because it will be unable
%%% to estimate the response without this value)
posR=[];
if missData.onResp
    pos_tmp=missData.ixMissResp;
    Gfprintf(' >>> Remove information (missing data at point(s):');
    fprintf(' %i',posR);
    fprintf('\n');
    %renumber for extracting right values
    pos_tmp=(pos_tmp-1)*(np+1)+1;
    for ii=1:numel(pos_tmp)
        posR=[posR pos_tmp(ii):pos_tmp(ii)+np+1];
    end
end

posG=[];
if missData.onGrad
    pos_tmp=missData.ixMissGrad;
    posG=(pos_tmp(:,1)-1)*(np+1)+1+pos_tmp(:,2);
end

%indexes of missing elements
ixMiss=unique([posR,posG]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create new responses (at added points)

%Reordering responses
tmpR=[respIn zeros(ns_init,np-1)];
reordR=reshape(tmpR',1,[]);
dupResp=repmat(reordR,np+1,1);
%Reordering gradients
reordGrad=reshape(gradIn',1,[]);
dupGrad=repmat(reordGrad,np+1,1);
tmp=matStepDup.*dupGrad;
%if missing data, sepcific proces for avoiding NaN
if missData.onGrad||missData.onResp
    IX=isnan(tmp(:));
    tmp(IX)=0;
end
badordS=dupResp+tmp;
%new responses
tmpR=zeros((np+1)*ns_init,np);
for ii=1:np
    li=ii:np:(np*ns_init);
    tmpR(:,ii)=reshape(badordS(:,li),(np+1)*ns_init,[]);
end
newResp=sum(tmpR,2);

%removes missing data
if ~isempty(ixMiss)
    newSampling(ixMiss,:)=[];
    newResp(ixMiss)=[];
end

end