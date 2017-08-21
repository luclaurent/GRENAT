%% core of kriging computation using QR factorization
function [detK,logDetK]=coreQR(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QR factorization
[obj.matrices.QK,obj.matrices.RK,obj.matrices.PK]=qr(obj.K);
%
diagRK=diag(obj.matrices.RK);
detK=abs(prod(diagRK)); %Q is an unitary matrix
logDetK=sum(log(abs(diagRK)));
%
obj.matrices.QtK=obj.matrices.QK';
yQ=obj.matrices.QtK*obj.YYtot;
fctQ=obj.matrices.QtK*obj.krgLS.XX;
obj.matrices.fcK=obj.krgLS.XX'*obj.matrices.PK/obj.matrices.RK;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute beta coefficient
obj.matrices.fcCfct=obj.matrices.fcK*fctQ;
block2=obj.matrices.fcK*yQ;
obj.beta=obj.matrices.fcCfct\block2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute gamma coefficient
obj.gamma=obj.matrices.PK*(obj.matrices.RK\(yQ-fctQ*obj.beta));
end
