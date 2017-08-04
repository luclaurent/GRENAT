%% check gradients
function iX=checkGrad(obj,gradIn)
%classical version
gradCheck=obj.grad;
runGrad=~obj.emptyGrad;
%version with input data
if nargin>1
    gradCheck=gradIn;
    runGrad=~isempty(gradCheck);
    
end
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