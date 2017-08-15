%% compute MSE
function variance=computeVariance(obj,rr,ff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute the prediction variance (MSE) (Lophaven, Nielsen & Sondergaard
%2004 / Marcelet 2008 / Chauvet 1999)
if ~dispWarning;warning off all;end
%depending on the factorization
switch obj.factKK
    case 'QR'
        rrP=rr'*obj.PK;
        Qrr=obj.QtK*rr;
        u=obj.fcR*Qrr-ff';
        variance=obj.sig2*(1-(rrP/obj.RK)*Qrr+...
            u'/obj.fcCfct*u);
    case 'LU'
        rrP=rr(obj.PK,:);
        Lrr=obj.LK\rrP;
        u=obj.fcU*Lrr-ff';
        variance=obj.sig2*(1-(rr'/obj.UK)*Lrr+...
            u'/obj.fcCfct*u);
    case 'LL'
        Lrr=obj.LK\rr;
        u=obj.fcL*Lrr-ff';
        variance=obj.sig2*(1-(rr'/obj.LtK)*Lrr+...
            u'/obj.fcCfct*u);
    otherwise
        rKrr=obj.KK \ rr;
        u=obj.fc*rKrr-ff';
        variance=obj.sig2*(1+u'/obj.fcCfct*u - rr'*rKrr);
end
if ~dispWarning;warning on all;end
end