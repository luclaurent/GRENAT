%% Evaluation of the metamodel
function [Z,GZ,variance]=eval(obj,X)
%computation of thr gradients or not (depending on the number of output variables)
if nargout>=2
    calcGrad=true;
else
    calcGrad=false;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ns=obj.nS;
np=obj.nP;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RBF/GRBF
%%compute response provided by the metamodel at the non sample point
%definition des dimensions of the matrix/vector for RBF or GRBF
if obj.flagG
    sizeMatVec=ns*(np+1);
else
    sizeMatVec=ns;
end

%kernel (correlation) vector between sample point and the non sample point
rr=zeros(sizeMatVec,1);
if calcGrad
    jr=zeros(sizeMatVec,np);
end
%RBF/GRBF
if obj.flagG
    if calcGrad  %if compute gradients
        %evaluate kernel function
        [ev,dev,ddev]=obj.kernelMatrix.buildVector(X,obj.paraVal);
        rr(1:ns)=ev;
        rr(ns+1:sizeMatVec)=-reshape(dev',1,ns*np);
        
        %derivative of the kernel vector between sample point and the non sample point
        jr(1:ns,:)=dev;
        
        % second derivatives
        matDer=zeros(np,np*ns);
        for mm=1:ns
            matDer(:,(mm-1)*np+1:mm*np)=ddev(:,:,mm);
        end
        jr(ns+1:sizeMatVec,:)=-matDer';
        
        %if missing data
        if obj.checkMiss
            rr=obj.missData.removeGRV(rr);
            jr=obj.missData.removeGRV(jr);
        end
    else %otherwise
        [ev,dev]=obj.kernelMatrix.buildVector(X,obj.paraVal);
        rr(1:ns)=ev;
        rr(ns+1:sizeMatVec)=-reshape(dev',1,ns*np);
        %if missing data
        if obj.checkMiss
            rr=obj.missData.removeGRV(rr);
        end
    end
else
    if calcGrad  %if the gradients will be computed
        [rr,jr]=obj.kernelMatrix.buildVector(X,obj.paraVal);
        %if missing data
        if obj.checkMiss
            rr=obj.missData.removeRV(rr);
            jr=obj.missData.removeRV(jr);
        end
    else %otherwise
        rr=obj.kernelMatrix.buildVector(X,obj.paraVal);
        %if missing data
        if obj.checkMiss
            rr=obj.missData.removeRV(rr);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%evaluation of the surrogate model at point X
Z=rr'*obj.W;
if calcGrad
    %%verif in 2D+
    GZ=jr'*obj.W;
end
%compute variance
if nargout >=3
    variance=obj.computeVariance(rr);
end
end
