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