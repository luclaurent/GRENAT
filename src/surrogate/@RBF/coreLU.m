
%% core of RBF computation using LU factorization
function coreLU(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LU factorization
[obj.matrices.LK,obj.matrices.UK,obj.matrices.PK]=lu(obj.K,'vector');
%
obj.matrices.iK=obj.matrices.UK\(obj.matrices.LK\obj.matrices.PK);
yL=obj.matrices.LK\obj.matrices.PK*obj.YYtot;
obj.W=obj.matrices.UK\yL;
%
end
