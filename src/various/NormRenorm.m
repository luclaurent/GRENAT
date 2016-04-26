%% Normalization and renormalization of the Data
%% L. LAURENT -- 18/10/2011 -- luc.laurent@lecnam.net

function [out,infoData]=NormRenorm(in,type,infoData)

% number of sample points
ns=size(in,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Dealing with all situations
NormData=false;MissNorm=false;
if nargin==3
    if isfield(infoData,'mean')
        if ~isempty(infoData.mean)
            NormData=true;
        else
            CalcParaNorm=false;
        end
    elseif isfield(infoData,'resp')
        MissNorm=infoData.resp.on;
        CalcParaNorm=true;
    elseif isfield(infoData,'mean')&&isfield(infoData,'resp')
        if ~isempty(infoData.mean)
            NormData=true;
        else
            CalcParaNorm=false;
        end
    end
else
    CalcParaNorm=true;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargout==2
    infoDataAvail=true;
else
    infoDataAvail=false;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation//renormalisation
switch type
    case 'norm'
        %if some data are missing, the NaN values are removed
        if MissNorm
            inm=in(infoData.resp.iXavail);
        else
            inm=in;
        end
        %if normalisation data are available
        if NormData
            meanN=infoData.mean;
            stdN=infoData.std;
            out=(in-meanN(ones(ns,1),:))./stdN(ones(ns,1),:);
            CalcParaNorm=false;
        end
        %if calculation of the normalisation data
        if CalcParaNorm
            %computation of the means and standard deviations
            meanI=mean(inm);
            stdI=std(inm);
            %test for checking standard deviation
            ind=find(stdI==0);
            if ~isempty(ind)
                stdI(ind)=1;
            end
            if MissNorm
                outm=(inm-meanI(ones(infoData.eval.nb,1),:))./...
                    stdI(ones(infoData.eval.nb,1),:);
                out=NaN*zeros(size(in));
                out(infoData.eval.ix_dispo)=outm;
            else
                out=(inm-meanI(ones(ns,1),:))./stdI(ones(ns,1),:);
            end
            %store normalisation data
            if infoDataAvail
                infoData.moy=meanI;
                infoData.std=stdI;
            end
        end
        if ~CalcParaNorm&&~NormData
            out=in;
        end
        
        %renormalisation
    case 'renorm'
        if NormData
            meanN=infoData.mean;
            stdN=infoData.std;
            out=stdN(ones(ns,1),:).*in+meanN(ones(ns,1),:);
        else
            out=in;
        end
        
        %renormalisation of the difference of two normalized data
    case 'renorm_diff'
        if NormData
            stdN=infoData.std;
            out=stdN(ones(ns,1),:).*in;
        else
            out=in;
        end
    otherwise
        error(['Wrong kind of normalisation/renormalisation (cf. ',mfilename,')'])
end
