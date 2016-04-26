%% normalization and renormalization of the gradient data
%% L. LAURENT -- 19/10/2011 -- luc.laurent@lecnam.net

function [out]=NormRenormG(in,type,infoData)

% number of sample points
nbs=size(in,1);
% normalisation of the data
if (nargin==3&&~isempty(infoData.std_t))||nargin==2
    switch type
        case 'norm'
            std_t=infoData.std_t;
            std_e=infoData.std_e;
            out=in.*std_t(ones(nbs,1),:)./std_e;
        case 'renorm'
            std_t=infoData.std_t;
            out=in*infoData.std_e./std_t(ones(nbs,1),:);
        case 'renorm_concat'  %concatenated gradients in a vector
            correct=infoData.std_e./infoData.std_t;
            nbv=numel(infoData.std_t);
            out=in.*repmat(correct(:),nbs/nbv,1);
        otherwise
            error(['Wrong kind of normalisation/renormalisation (cf. ',mfilename,')'])
            
    end
else
    out=in;
end

