%% core of kriging computation using LU factorization
function [detK,logDetK]=coreLU(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LU factorization
[obj.matrices.LK,obj.matrices.UK,obj.matrices.PK]=lu(obj.K,'vector');
%
diagUK=diag(obj.matrices.UK);
detK=prod(diagUK); %L is a quasi-triangular matrix and contains ones on the diagonal
logDetK=sum(log(abs(diagUK)));
%
yP=obj.YYtot(obj.matrices.PK,:);
fctP=obj.krgLS.XX(obj.matrices.PK,:);
yL=obj.matrices.LK\yP;
fctL=obj.matrices.LK\fctP;
obj.matrices.fcU=obj.krgLS.XX'/obj.matrices.UK;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute beta coefficient
obj.matrices.fcCfct=obj.matrices.fcU*fctL;
block2=obj.matrices.fcU*yL;
obj.beta=obj.matrices.fcCfct\block2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute gamma coefficient
obj.gamma=obj.matrices.UK\(yL-fctL*obj.beta);
end