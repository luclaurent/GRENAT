%% core of kriging computation using no factorization
function [detK,logDetK]=coreClassical(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%classical approach
eigVal=eig(obj.K);
detK=prod(eigVal);
logDetK=sum(log(eigVal));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute gamma and beta coefficients
obj.matrices.fcC=obj.krgLS.XX'/obj.K;
obj.matrices.fcCfct=obj.matrices.fcC*obj.krgLS.XX;
block2=((obj.krgLS.XX'/obj.K)*obj.YYtot);
obj.beta=obj.matrices.fcCfct\block2;
obj.gamma=obj.K\(obj.YYtot-obj.krgLS.XX*obj.beta);
end