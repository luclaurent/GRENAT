
%% core of RBF computation using no factorization
function coreClassical(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%classical approach
obj.W=obj.K\obj.YYtot;
end
