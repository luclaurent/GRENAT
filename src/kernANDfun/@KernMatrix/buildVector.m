%% Method of KernMatrix class
% L. LAURENT -- 18/07/2017 -- luc.laurent@lecnam.net

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


%% Build a correlation (kernel) vector depending on the distance between existing sample points and specific points
% INPUTS:
% - samplePts: sample points on which the vector will be calculated
% - paraV: values of the hyperparameters used for kernel computation
% (optional)
% OUTPUTS:
% - V,Vd,Vdd: kernel vectors (V: responses, Vd: gradients and Vdd:
% hessians) 

function [V,Vd,Vdd]=buildVector(obj,samplePts,paraV)
%obj.init;
%changing the values of the internal parameters
if nargin>1;obj.paraVal=paraV;end
%depending on the number of output arguments
if nargout>1;computeGrad=true;end
%compute distance
distS=repmat(samplePts,obj.nS,1)-obj.sampling;
%
fctK=obj.fctKern;
pVl=obj.paraVal;
%if derivatives required
if computeGrad
    %if parallel workers are available
    if obj.parallelOk
                %                         parfor ii=1:ns
        %                             %Building by column & evaluation of the Kernel function
        %                             [V(,dev,ddev]=multiKernel(fctK,dC(:,ii),pVl);
        %                             %classical part
        %                             KK(:,ii)=ev;
        %                             %part of the first derivatives
        %                             KKa{ii}=dev;
        %                             %part of the second derivatives
        %                             KKi{ii}=reshape(ddev,np,ns*np);
        %                         end
        %                         %Reordering matrices
        %                         KKd=horzcat(KKa{:});
        %                         KKdd=vertcat(KKi{:});
    else
        %evaluation of the kernel function for all inter-points
        %keyboard
        [V,Vd,Vdd]=multiKernel(fctK,distS,pVl);
    end
else
    if obj.parallelOk
        %REWRITE
        %                         %%%%%% PARALLEL %%%%%%
        %                         %classical kernel matrix by column
        %                         KK=zeros(ns,ns);
        %                         parfor ii=1:ns
        %                             % evaluate kernel function
        %                             [ev]=multiKernel(fctK,dC(:,ii),pVl);
        %                             % kernel matrix by column
        %                             KK(:,ii)=ev;
        %                         end
    else
        % evaluate kernel function
        [V]=multiKernel(fctK,distS,pVl);
    end
end
end