
%% core of RBF computation using Cholesky (LL) factorization
function coreLL(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Cholesky's fatorization
%%% to be degugged
obj.matrices.LK=chol(obj.K,'lower');
%
obj.matrices.iK=obj.matrices.LK'\inv(obj.matrices.LK);
yL=obj.matrices.LK\obj.YYtot;
obj.W=obj.matrices.LK'\yL;
%

end