%% Function for evaluating the monomial terms and builds matrix of regressors
% L. LAURENT -- 07/02/2017 -- luc.laurent@lecnam.net

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

function [matX,matDX,matDDX]=MultiMono(X,polyOrder)
%number of sample points
ns=size(X,1);
%number of design variables
np=size(X,2);

%choose polynomial function
funPoly=['mono_' num2str(polyOrder,'%02i') '_' num2str(np,'%03i')];
%check if the function exist (if not create it)
if ~exist(funPoly,'file')
    toolGeneMonomial(polyOrder,np);
end

%deal with what quantities is required
derFirst=false;
derSecond=false;
if nargout==2
    derFirst=true;
elseif nargout==3
    derFirst=true;
    derSecond=true;
end

%extract data
if derSecond
    [poly,polyD,polyDD]=feval(funPoly);
elseif derFirst
    [poly,polyD]=feval(funPoly);
else
    [poly]=feval(funPoly);
end

%X reshaped
Xr=reshape(X,[ns,1,np]);

%evaluation
matX=prod(Xr.^poly.Xpow,3);
%first derivatives
if derFirst
    matTmpA=zeros(ns,poly.nbMono,np);
    matTmpA(:)=prod(Xr(:,:,:,ones(1,np)).^polyD.Xpow,3);
    matTmpB=polyD.Xcoef(ones(1,ns),:,:).*matTmpA;
   % matDX=reshape(permute(matTmpB,[1 3 2]),np*ns,poly.nbMono);
    matDX=reshape(horzcat(matTmpB(:,:))',poly.nbMono,[])';
end

%second derivatives
if derSecond
    matTmpA=zeros(ns,poly.nbMono,np*np);
    matTmpA(:)=prod(Xr(:,:,:,ones(1,np*np)).^polyDD.Xpow,3);
    matTmpB=polyDD.Xcoef(ones(1,ns),:,:).*matTmpA;
    %matDDX=reshape(permute(matTmpB,[1 3 2]),np*np*ns,poly.nbMono);
    matDX=reshape(horzcat(matTmpB(:,:))',poly.nbMono,[])';
end
end
