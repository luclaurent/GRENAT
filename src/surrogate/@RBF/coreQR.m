

%% core of RBF computation using QR factorization
function coreQR(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QR factorization
[obj.matrices.QK,obj.matrices.RK,obj.matrices.PK]=qr(obj.K);
%
obj.matrices.iK=obj.matrices.PK*(obj.matrices.RK\obj.matrices.QK');
yQ=obj.matrices.QK'*obj.YYtot;
obj.W=obj.matrices.PK*(obj.matrices.RK\yQ);
%
end