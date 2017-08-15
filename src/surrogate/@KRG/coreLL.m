%% core of kriging computation using Cholesky (LL) factorization
function [detK,logDetK]=coreLL(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Cholesky's fatorization
%%% to be degugged
obj.matrices.LK=chol(obj.K,'lower');
%
diagLK=diag(obj.matrices.LK);
detK=prod(diagLK)^2;
logDetK=2*sum(log(abs(diagLK)));
%
LtK=obj.matrices.LK';
yL=obj.matrices.LK\obj.YYtot;
fctL=obj.matrices.LK\obj.krgLS.XX;
obj.matrices.fcL=obj.krgLS.XX'/LtK;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute beta coefficient
obj.matrices.fcCfct=obj.matrices.fcL*fctL;
block2=obj.matrices.fcL*yL;
obj.beta=obj.matrices.fcCfct\block2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute gamma coefficient
obj.gamma=LtK\(yL-fctL*obj.beta);
end