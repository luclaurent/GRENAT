%% Function for calculating error of LOO (Cross-Validation)
%% L. LAURENT -- 22/10/2012 -- luc.laurent@lecnam.net

function [ret]=LOOCalcError(Zref,Zap,variance,GZref,GZap,ns,np,LOO_norm)

%check availability of the gradients
availGrad=true;
if isempty(GZref)
    availGrad=false;
end
%check calculation of SCVR
availVar=true;
if isempty(variance)
    availVar=false;
end

%diff responses
diffZ=Zap-Zref;
if availGrad
    %diff gradients
    diffG=GZap-GZref;
end
%diff responses (choice of the norm)
switch LOO_norm
    case 'L1'
        diffC=abs(diffZ);
    case 'L2'
        diffC=diffZ.^2;
    case 'Linf'
        diffC=max(diffZ(:));
end
%Custom criterion
somm=0.5*(Zap+Zref);
ret.errp=1/ns*sum(abs(diffZ)./somm);
%PRESS
ret.press=sum(diffC);
%mean bias
ret.bm=1/ns*sum(diffZ);
if availGrad
    %diff gradients (choice of the norm)
    switch LOO_norm
        case 'L1'
            diffgc=abs(diffG);
        case 'L2'
            diffgc=diffZ.^2;
        case 'Linf'
            diffgc=max(diffG);
    end
    %mean of the differences on responsesn gradients and both squared
    ret.eloor=1/ns*sum(diffC);
    ret.eloog=1/(ns*np)*sum(diffgc(:));
    ret.eloot=1/(ns*(1+np))*(sum(diffC)+sum(diffgc(:)));
else
    %mean diff responses
    ret.eloor=1/ns*sum(diffC);
    ret.eloot=ret.eloor;
end
if availVar
    %criterion of adequation (SCVR Keane 2005/Jones 1998)
    ret.scvr=diffZ./variance;
    ret.scvr_min=min(ret.scvr(:));
    ret.scvr_max=max(ret.scvr(:));
    ret.scvr_mean=mean(ret.scvr(:));
    %%criterion of adequation (CAUTION of the norm!!!>> squared difference)
    diffA=diffC./variance;
    ret.adequ=1/ns*sum(diffA);
end
