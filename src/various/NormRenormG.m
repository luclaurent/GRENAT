%% normalization and renormalization of the gradient data
%% L. LAURENT -- 19/10/2011 -- luc.laurent@lecnam.net

function [out]=NormRenormG(in,type,infoDataS,infoDataR)

% number of sample points
ns=size(in,1);
% normalisation of the data
if (nargin==3&&~isempty(infoDataS.std))||nargin==2
    switch type
        case 'norm'
            stdS=infoDataS.std;
            stdR=infoDataR.std;
            out=in.*stdS(ones(ns,1),:)./stdR;
        case 'renorm'
            stdS=infoDataS.std;
            stdR=infoDataR.std;
            out=in*stdR./stdS(ones(ns,1),:);
        case 'renorm_concat'  %concatenated gradients in a vector
            stdS=infoDataS.std;
            stdR=infoDataR.std;
            correct=stdR./stdS;
            nbv=numel(stdS);
            out=in.*repmat(correct(:),ns/nbv,1);
        otherwise
            error(['Wrong kind of normalisation/renormalisation (cf. ',mfilename,')'])
            
    end
else
    out=in;
end

