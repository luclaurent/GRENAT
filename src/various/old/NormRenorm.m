%% Normalization and renormalization of the Data
% L. LAURENT -- 18/10/2011 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox 
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017  Luc LAURENT <luc.laurent@lecnam.net>
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
                outm=(inm-meanI(ones(infoData.resp.nb,1),:))./...
                    stdI(ones(infoData.resp.nb,1),:);
                out=NaN*zeros(size(in));
                out(infoData.resp.iXavail)=outm;
            else
                out=(inm-meanI(ones(ns,1),:))./stdI(ones(ns,1),:);
            end
            %store normalisation data
            if infoDataAvail
                infoData.mean=meanI;
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
        Gfprintf('Wrong kind of normalisation/renormalisation');
        error(['Error in ' mfilename ]);
end
