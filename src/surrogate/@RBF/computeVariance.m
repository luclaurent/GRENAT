

%% compute MSE
function variance=computeVariance(obj,rr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute variance of the surrogate model (Bompard 2011,Sobester 2005, Gibbs 1997)
if ~dispWarning;warning off all;end
%correction for taking into account gradients (debug ....)
rrb=rr;
if obj.flagG
    iXs=ns+1-obj.missData.nbMissResp;
    rrb(iXs:end)=-rrb(iXs:end);
end
%
variance=1-rr*(obj.matrices.iK*rrb');
if ~dispWarning;warning on all;end
end
