%% normalization and renormalization of the gradient data
% L. LAURENT -- 19/10/2011 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox 
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016  Luc LAURENT <luc.laurent@lecnam.net>
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

function [out]=NormRenormG(in,type,infoDataS,infoDataR)

% number of sample points
ns=size(in,1);
% normalisation of the data
if (nargin>=3&&~isempty(infoDataS.std))||nargin==2
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
            Gfprintf('Wrong kind of normalisation/renormalisation');
            error(['Error in ' mfilename ]);
    end
else
    out=in;
end

